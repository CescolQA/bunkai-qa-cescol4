# Checkpoint 0 — Punto de partida

> Alinea de dónde salimos: qué pide la historia (ACs) y qué agrega el reconocimiento técnico que no estaba en el brief.

---

## 1. Las 5 ACs de BK-859

Fuente: `.context/PBI/.../STORY-BK-859-.../acceptance-criteria.md` (sincronizado de Jira, reconciliado 2026-08-05).

| ID | Escenario | Qué afirma | Resultado esperado |
|---|---|---|---|
| **S1** | Dejar un workspace pide confirmación | Con 2+ workspaces, al elegir "Leave workspace" aparece un diálogo que **nombra** el workspace antes de confirmar | Al confirmar: se borra la membership, el workspace desaparece de la lista, el activo cae al otro que queda (regla BR-1: "membership restante más vieja"), el switcher global refleja el nuevo activo |
| **S2** | No se puede dejar un workspace que se posee en soledad | Sos `owner` y no hay otro `owner` en ese workspace | La acción "Leave workspace" está **deshabilitada u oculta** + mensaje que explica que sos el único owner y que hay que transferir/compartir ownership antes de irse |
| **A** | Dejar el único workspace del usuario | Pertenecés a exactamente 1 workspace (rol `member`, no sole owner) | La acción **no se renderiza** (mismo trato que S2). No hay diálogo de confirmación alcanzable |
| **B** | Sin efecto cascada sobre el contenido del workspace, PAT incluido | El que se va autoró ATCs y user stories, y tiene un PAT con scope de ese workspace | El contenido queda **intacto** dentro del workspace; el que se fue ya no lo ve ni accede; el PAT con scope de ese workspace queda **auto-revocado en la misma transacción** |
| **C** | Un co-owner puede irse si quedan otros owners | El workspace tiene 2 miembros con rol `owner` (vos y otra persona) | La acción **está disponible**; sigue el mismo flujo de confirmación que S1; al confirmar, el workspace conserva al otro owner con privilegios intactos |

### Pregunta abierta que sigue sin respuesta

El **mecanismo del diálogo de confirmación** de S1 (confirmar/cancelar simple vs. escribir-para-confirmar) no tiene respuesta de diseño autoritativa. Anotado en la AC como *open question*. Impacto en el diseño: los casos de S1 se dejan **agnósticos del mecanismo** hasta que Diseño/Dev respondan.

---

## 2. Qué agrega el reconocimiento (y no estaba en el brief)

Fuente: `../reconocimiento-hallazgos-SELLADO.md` (corrida read-only contra staging, 2026-09-08).

### 2.1. El orden de los guards del RPC importa

`bunkai_leave_workspace(p_workspace_id uuid)` chequea en **este orden exacto** (leído de `pg_get_functiondef`, es autoritativo):

| # | Condición que corta | Excepción | SQLSTATE | HTTP que devuelve la API |
|---|---|---|---|---|
| 1 | `auth.uid()` es null (no autenticado) | `not_authenticated` | `42501` | `401` |
| 2 | El llamador no tiene fila `status='active'` en ese workspace | `not_a_member` | `P0002` | `404` |
| 3 | El total de membresías `status='active'` del llamador es `<= 1` | `last_membership` | `45212` | `409` |
| 4 | El llamador es `role='owner'` **y** la cantidad de *otros* owners activos es `0` | `sole_owner` | `45213` | `409` |
| 5 | (pasa todo) `DELETE` de la fila de `workspace_members` — **hard delete** | — | — | `200` |
| 6 | `UPDATE access_tokens SET revoked_at = now()` para los PAT con scope de ese workspace | — | — | (parte del `200`) |

**Por qué importa el orden**: si probás con un usuario que tiene 1 sola membresía Y es sole owner de ese workspace, el error que vas a ver es `last_membership` (guard 3), **no** `sole_owner` (guard 4). Para provocar `sole_owner` puro necesitás **2+ membresías** y ser único owner del target. Esto define fixtures distintos.

### 2.2. El contrato de la API

`DELETE /api/v1/workspaces/{id}/membership` — `security: [cookieAuth]`, sin body.

| Código | Cuándo |
|---|---|
| `200` `WorkspaceLeaveResponse` | Éxito. Body: `{ newActiveWorkspaceId: uuid\|null, newActiveWorkspaceName: string\|null }`, ambos requeridos. Si dejaste tu workspace activo, la response trae el activo re-resuelto (**membership restante más vieja, `joined_at asc`**) y **rota la cookie `bk_active_ws`** en la misma response |
| `401` | No autenticado |
| `403` | Autenticado por **PAT** (los PAT no pueden dejar un workspace — es 1 de las 4 rutas cookie-only) |
| `404` | El workspace no existe **o** el llamador no es miembro activo (mapea `not_a_member` / `P0002`) |
| `409` | `last_membership` **o** `sole_owner` (mapea `45212` / `45213`) |

### 2.3. Hallazgos que se convierten en casos de prueba

| # | Hallazgo | Qué probar por esto |
|---|---|---|
| H1 | Los dos `409` **no** tienen un `code` dedicado en el `ErrorEnvelope`. El enum de `code` solo tiene genéricos (`conflict`, `forbidden`, ...). El cliente distingue `last_membership` de `sole_owner` por `message`/`details` | Verificar que el `message`/`details` de cada `409` permite distinguir el motivo. Si no se puede → **candidato a improvement** (ver `07`) |
| H2 | La membership se borra **hard** (`DELETE`), no pasa a `suspended`. `suspended` retiene la fila | Tras irse, la fila **no existe** en `workspace_members` (validar por DB). Un segundo intento de leave debe dar `404`, no otro error |
| H3 | El workspace activo se re-resuelve en la **capa de API**, no en el RPC. Regla: membership restante más vieja por `joined_at asc`. Rota `bk_active_ws` | Probar que al dejar el activo, el nuevo activo es el más viejo de los que quedan, y que la cookie cambió |
| H4 | El PAT auto-revocado es **solo** el que tiene scope del workspace que se deja. Un PAT de otro workspace no se toca | Dos PAT (uno del target, uno de otro workspace): tras irse, el primero da `401` al usarlo, el segundo sigue vivo |
| H5 | El `role='admin'` cuenta como **no-owner** para los guards. El guard mira `role='owner'`, no `admin` | Un `admin` que se va no dispara `sole_owner` aunque sea el único admin |
| H6 | El schema **no impide** múltiples `owner` por workspace (no hay unique index parcial). El guard es puro conteo | El fixture C (co-owner) es válido a nivel schema; el bloqueo es solo por conteo |
| H7 | Existe `DELETE /api/v1/workspaces/{id}` (borrar workspace, owner-only, session-only) que comparte la lógica "activo = más viejo restante" + rotación de cookie | Fuera del scope de BK-859, pero anotarlo: misma lógica compartida = si se rompe una, mirar la otra |
| H8 | Calidad de datos en staging: **15 workspaces sin borrar tienen 0 owners activos** + 2 filas `owner/suspended`. La regla de negocio BR-8 (siempre >=1 owner) no se cumple en los datos ya existentes | No elegir esos workspaces como fixture. Verificar el estado de owners **antes** de cada prueba |

### 2.4. Riesgo de la ruta agéntica (viene de la pasada ciega)

La pasada ciega marcó como edge case: *"escenarios donde pueda permitirse dejar el workspace por instrucciones alternativas por IA agéntica"*.

El RPC es `SECURITY DEFINER` con `SET search_path = ''`. Cualquier ruta que llegue a `bunkai_leave_workspace` — API directa o IA agéntica — pasa por **los mismos 4 guards**. El caso de prueba correspondiente: confirmar que la ruta agéntica **no tiene un bypass** que salte los guards (ver Error-Guessing en `04`).

---

## Qué revisar en este checkpoint

- [ ] Las 5 ACs están entendidas y ninguna quedó sin mapear a un escenario de membership
- [ ] El orden de los 4 guards está claro, y por qué `last_membership` "tapa" a `sole_owner` cuando el usuario tiene 1 sola membresía
- [ ] Los 4 códigos HTTP (`401` / `403` / `404` / `409`) están asociados a su causa
- [ ] Los 8 hallazgos (H1–H8) tienen al menos una idea de prueba asociada
- [ ] El hallazgo H1 (dos `409` sin `code` dedicado) queda marcado como posible *improvement*
