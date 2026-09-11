# BK-859 - Hallazgos de reconocimiento (SELLADO hasta la pasada ciega)

> NO ABRIR antes de terminar tu pasada ciega de diseño de pruebas (paso 4).
> Este archivo contiene detalle de implementación recuperado del RPC y del contrato de API en la corrida de reconocimiento del 2026-09-08. Te masticaría los edge cases. Se abre en el paso 5 (pasada asistida).
>
> Origen: corrida read-only contra staging. Browser bloqueado por credencial vencida; DB (DBHub) y schema de API (OpenAPI MCP) completos. Sin escrituras.

---

## 1. RPC `public.bunkai_leave_workspace(p_workspace_id uuid)`

`RETURNS void`, `SECURITY DEFINER`, `SET search_path = ''`. Orden de guards leído de `pg_get_functiondef` (autoritativo):

| # | Condición | Excepción | SQLSTATE |
|---|---|---|---|
| 1 | `auth.uid()` es null | `not_authenticated` | `42501` |
| 2 | El llamador no tiene fila `status='active'` en ese workspace | `not_a_member` | `P0002` |
| 3 | El total de membresías `status='active'` del llamador es `<= 1` | `last_membership` | `45212` |
| 4 | El role del llamador es `owner` **y** la cantidad de *otros* owners activos es `0` | `sole_owner` | `45213` |
| 5 | (pasa los guards) `DELETE FROM public.workspace_members WHERE workspace_id = ... AND user_id = ...` | **hard delete** de la fila | - |
| 6 | `UPDATE public.access_tokens SET revoked_at = now() WHERE user_id = <llamador> AND workspace_id = <target> AND revoked_at IS NULL` | PATs con scope de ese workspace del que se va: **auto-revocados en la misma transacción** | - |

El RPC **no toca** el active-workspace. Ese fallback se resuelve en la capa de API.

## 2. Contrato `DELETE /api/v1/workspaces/{id}/membership`

`security: [{cookieAuth: []}]`, sin body de request.

| Código | Significado |
|---|---|
| **200** `WorkspaceLeaveResponse` | `{ newActiveWorkspaceId: uuid\|null, newActiveWorkspaceName: string\|null }` (ambos requeridos). Si el workspace que dejaste era tu activo, la response trae el activo re-resuelto = **"membership restante más vieja primero"** (`joined_at asc`) y rota la cookie `bk_active_ws` en la misma response. PATs del que se va revocados. |
| **401** | no autenticado |
| **403** | autenticado vía PAT (los PAT no pueden dejar un workspace: 1 de las 4 rutas cookie-only) |
| **404** | workspace no existe **o** el llamador no es miembro activo (mapea `not_a_member` / `P0002`) |
| **409** | `last_membership` **o** `sole_owner` (mapea `45212` / `45213`) |

`ErrorEnvelope` = `{ error: { code, message, details?, request_id? } }`. El enum de `code` solo tiene valores genéricos (`conflict`, `forbidden`, `not_found`, `unauthorized`, ...). **No hay un `code` dedicado para `last_membership` vs `sole_owner`**: el cliente tiene que distinguir los dos 409 por `message` / `details`.

## 3. Respuestas a las preguntas que el brief dejó abiertas

| Pregunta abierta en el brief | Respuesta del reconocimiento |
|---|---|
| Shape de request/response y status de éxito | 200, body `WorkspaceLeaveResponse` (arriba). Sin body de request. |
| Qué workspace queda activo tras irse | La membership restante más vieja (`joined_at asc`). Devuelto en la response, cookie rotada. Lógica en la capa de API, no en el RPC. |
| ¿Se auto-revoca un PAT con scope de workspace del que se va? | Sí. Paso 6 del RPC, solo los PAT con scope de ese workspace. |
| ¿La fila de membership se borra hard o se retiene? | **Hard delete** (`DELETE FROM public.workspace_members`). Distinto de `suspended`, que retiene la fila. |
| UX de co-owner que se va | Sigue sin verse (browser bloqueado). A nivel server: guard #4 es por conteo, un co-owner con otro owner activo pasa. |

## 4. Correcciones factuales al `business-context-brief.md`

| El brief decía | Realidad en staging |
|---|---|
| "No existe `DELETE /api/v1/workspaces/{id}`" | **Sí existe.** Owner-only, session-only (BK-512, ADR-0015). Soft-delete + 30 días de gracia + `POST /api/v1/workspaces/{id}/restore`. Revoca PATs del workspace y invites pendientes, mailea a todos los miembros. Comparte con leave la lógica "activo = más viejo restante" + rotación de cookie. |
| `status` enum = `active \| suspended` | CHECK real = `active \| invited \| suspended` |
| Guard `last_membership` = SQLSTATE `45212`, `sole_owner` = `45213` | Confirmado. Más: `not_authenticated` `42501`, `not_a_member` `P0002`. |
| Schema no impide múltiples `owner` por workspace | Confirmado (no hay unique index parcial). Guard es puro conteo. |

## 5. Adyacencias que en staging están más pobladas de lo que el brief implica

Endpoints `Workspaces` presentes en staging (además de leave):
- `POST /api/v1/workspaces` (crear + auto-enrolar owner, wrap de `bunkai_bootstrap_workspace`)
- `DELETE /api/v1/workspaces/{id}` (borrar) + `POST .../restore`
- `PATCH /api/v1/workspaces/{id}` (owner-only, hoy solo `name` mutable)
- `GET/POST .../invites`, `POST/DELETE .../invites/{inviteId}` (gestión de invites)
- `POST /api/v1/me/active-workspace` (dual-auth, setea cookie `bk_active_ws`)
- Sin endpoint: transferencia de ownership; cambio de role/status de un miembro (`active <-> suspended`, promover co-owner). Coincide con el brief.

## 6. Estado de datos de staging (contexto, no es tu user)

- 585 workspaces, 594 filas de membership, 79 usuarios, 6917 access_tokens.
- owner/active 571, member/active 14, viewer/active 6, owner/suspended 2, admin/active 1.
- 14 usuarios con >=2 membresías activas; 65 con exactamente 1.
- Escenarios "co-owner se va" y "member simple se va" son **raros** en los datos de staging (~21 filas activas no-owner en toda la instancia). Vas a tener que construir esos fixtures.
- Ojo calidad de datos: 15 workspaces no borrados tienen **cero owners activos** + 2 filas owner/suspended. BR-8 no se cumple en los datos ya existentes de staging. Puede ensuciar la selección de escenarios.
