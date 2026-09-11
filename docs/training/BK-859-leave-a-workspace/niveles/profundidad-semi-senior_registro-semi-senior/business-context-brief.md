# BK-859 - Brief de contexto de negocio (acotado)

> Digesto acotado a la historia, para entrenamiento. Solo contexto de negocio. Excluye el plan de implementación del dev y los defectos históricos, por diseño.

> Archivo de trabajo, no sincronizado con Jira. Destilado de los cuatro mapas de negocio del proyecto más el glosario de dominio y el master test plan, reducido a lo relevante para "Leave a workspace" (dejar un workspace), para que un analista humano arranque una pasada ciega de diseño de pruebas con el mismo material que tendría una IA por haber leído todos los mapas, y no con un ticket de Jira pelado.

> Nota de idioma: los artefactos de las prácticas de entrenamiento se escriben en castellano a pedido del usuario. Los identificadores tecnicos, nombres de tablas y columnas, enums, rutas de endpoints, nombres de RPC, codigos SQLSTATE y rutas de archivo se dejan textuales.

## 1. Resumen de la feature - FEAT-012 "Leave Workspace"

Un miembro puede quitar su propia membresía de un workspace que ya no necesita, para que su cuenta quede acotada a los equipos con los que realmente trabaja. Es una acción self-service y self-only: elimina la fila `workspace_members` del propio llamador, no elimina a nadie más, y no toca el contenido del workspace. Está protegida por una invariante de negocio (BR-8): un workspace nunca puede quedar sin owner, y un usuario nunca puede quedar con cero workspaces. El endpoint de auto-baja del backend es trabajo nuevo de esta historia: no existía ningún endpoint así antes, y el guard debe aplicarse del lado del servidor, no solo en la UI.

## 2. Modelo de datos y entidades

| Entidad | Tabla | Atributos clave | Relevancia para "Leave" |
|---|---|---|---|
| Workspace Membership | `public.workspace_members` | `workspace_id` + `user_id` (PK compuesta), `role` (`viewer`\|`member`\|`admin`\|`owner`), `status` (`active`\|`invited`\|`suspended`), `joined_at` | La fila que "leave" elimina. El schema NO impide múltiples filas `owner` por workspace. |
| Workspace | `public.workspaces` | `id`, `slug`, `name`, `owner_user_id`, `plan` | Límite de tenant; `owner_user_id` es el owner de bootstrap, distinto de las filas del roster con `role='owner'`. |
| Personal Access Token (PAT) | `access_tokens` (+ `access_token_secrets`) | scope de workspace, `scopes[]` | Un usuario que se va puede tener un PAT con scope de workspace. Los mapas muestran la revocación de PAT como una operación separada (ver sección 4). |

Máquina de estados (`business-data-map.md §4.4`, glosario §6.4): `active --leave/removed--> [*]` vía `bunkai_leave_workspace`. Contrastar con `active <-> suspended`, que retiene la fila; "leave" es una eliminación terminal.

## 3. Subconjunto del glosario de dominio

| Término | Significado en este contexto |
|---|---|
| Workspace | Tenant / cuenta de cliente; el límite de aislamiento para toda otra entidad. |
| Workspace Membership | El `role` + `status` de un usuario dentro de un workspace (la fila join de RBAC). |
| Owner (`role='owner'`) | Control total; único role que puede borrar el workspace; siempre debe quedar al menos un owner activo. |
| Sole owner (owner único) | El único miembro del workspace cuyo role es `owner`, bloqueado para irse. |
| Co-owner | Un miembro con `role='owner'` cuando existe al menos otro owner, no lo bloquea el guard de sole-owner. |
| Active workspace | El workspace seleccionado actualmente para la sesión (`POST /api/v1/me/active-workspace`, FEAT-005). |
| Guard `last_membership` | Rechazo cuando el workspace que se intenta dejar es la única membresía activa del llamador (SQLSTATE `45212`). |
| Guard `sole_owner` | Rechazo cuando el llamador es el único owner activo (SQLSTATE `45213`). |
| PAT | Personal Access Token; credencial bearer para llamadas de CLI/CI/agente, con scope de un solo workspace. |
| RLS | Row-Level Security; la capa de Postgres que es el verdadero límite de autorización, un no-miembro obtiene cero filas, no un error. |
| RPC | Una función de Postgres invocada vía `supabase.rpc()`; acá `bunkai_leave_workspace`. |
| SECURITY DEFINER | Una RPC que corre con los privilegios del definer (patrón usado en otras partes de este schema para escrituras controladas). |

## 4. Contrato de API / RPC

| Aspecto | Valor |
|---|---|
| Endpoint | `DELETE /api/v1/workspaces/{id}/membership` |
| Nivel de auth | Cookie-only, 1 de exactamente 4 operaciones donde un PAT está explícitamente excluido (`business-api-map.md §2`, `business-feature-map.md §7`). Un PAT "no puede hacer que su propio owner deje un workspace". |
| RPC de respaldo | `bunkai_leave_workspace` (`supabase/migrations/0044_leave_workspace.sql`) |
| Rechazos | `last_membership` (`45212`) - única membresía activa del llamador; `sole_owner` (`45213`) - el llamador es el único owner activo |
| UI | `components/settings/LeaveWorkspaceModal.tsx`; lista de workspaces en `app/(app)/settings/workspaces/page.tsx` (`WorkspacesList.tsx`) |
| Operación adyacente | `POST /api/v1/me/active-workspace` (auth dual) - define el active workspace de la sesión |

Shape del body de request y response (campos del payload, status code de éxito, envoltura de la response): **no especificado en los mapas del proyecto** - el api-map documenta solo la ruta del endpoint y su nivel de auth, sin un journey dedicado de request/response para esta operación.

## 5. Reglas de negocio y condiciones de guard (nivel de negocio)

- **BR-8 - un workspace siempre debe retener al menos un owner activo** (`domain-glossary.md` BR-8, `business-data-map.md §3.1 / §4.4`). Dos modos de fallo: (a) no podés dejar tu único workspace; (b) el único owner restante no puede irse mientras no exista otro owner.
- **El guard es por conteo, no por identidad.** La máquina de estados lo formula como "el llamador es el único owner activo", así que un co-owner que se va mientras queda otro owner no está bloqueado por BR-8. Nota: los mapas describen esto solo a nivel schema/RPC; no describen ninguna UX de co-owner que se va.
- **Se requiere enforcement del lado del servidor** - `scope.md` indica que el guard de sole-owner debe aplicarse del lado del servidor; un disable solo-UI no alcanza.
- **El bootstrap siempre crea exactamente un owner** (FEAT-008); BR-8 solo se chequea al momento de irse, nunca en la creación.
- **Irse elimina la fila de membership** (terminal `active -> removed`), lo cual es distinto de `suspended` (fila retenida, acceso revocado).
- **Fallback de active-workspace después de irse** (qué workspace pasa a estar activo): **no especificado en los mapas del proyecto.** La historia referencia una "regla de resolución de active-workspace usada en otras partes"; la BR-1 del glosario es una regla de ATC no relacionada.
- **Auto-revocación de PAT cuando un usuario se va:** **no especificado en los mapas del proyecto.** La revocación de PAT es una operación Cookie-only separada (`DELETE /api/v1/tokens/{id}`); no hay cascada documentada desde "leave workspace".
- **Contenido propiedad del workspace** (ATCs, user stories, módulos, proyectos creados por quien se va): los mapas no documentan ningún camino de borrado/cascada ligado a la membresía. RLS simplemente deja de devolver las filas de ese workspace a un ex-miembro.

## 6. Features adyacentes y dónde está el límite

| Feature | Relación | ¿En scope para BK-859? |
|---|---|---|
| FEAT-008 Workspace Creation + Owner Bootstrap | Produce el único owner que BR-8 después protege | No - upstream |
| FEAT-010 / FEAT-011 Invite Lifecycle + Acceptance | El camino de entrada a la membresía; `owner` no es invitable | No - flujo inverso |
| FEAT-013 Workspace Member Role/Status Management | Transiciones `active <-> suspended`; la transferencia de ownership / promover un co-owner viviría acá | No - Planned/no confirmado, sin endpoint localizado; la transferencia de ownership es explícitamente Phase 2 (`out-of-scope.md`) |
| Workspace delete/archive | **Sí existe** `DELETE /api/v1/workspaces/{id}` (corrección del reconocimiento 2026-09-08): owner-only, session-only, soft-delete + 30 días de gracia + `POST .../restore` (BK-512, ADR-0015). Comparte con "leave" la lógica de re-resolver el active-workspace + rotar cookie. | No - fuera de scope de BK-859, pero es adyacencia real, no inexistente |
| FEAT-006 PAT Management | Operación de revocación separada | Solo relevante como pregunta abierta sobre cascada |
| FEAT-005 Session + Active Workspace | El switch que refleja el active workspace post-leave | Adyacente - el comportamiento de fallback que dispara no está detallado en los mapas |

## 7. Notas de riesgo (de `master-test-plan.md`)

- **§4.3 Workspace Member Status.** Los guards de BR-8 se destacan como "vale la pena probarlos directamente", incluyendo el edge case de orden: el anteúltimo owner que se va debería tener éxito, y el verdadero último owner que se va inmediatamente después debería fallar - la invariante debe sostenerse a través de una transición de estado, no solo en una foto estática (también ítems de checklist en las líneas 334 y 360).
- **§3.1 Cross-Workspace Tenant Isolation (rank: CRITICAL, riesgo #1 del producto).** Después de que un usuario se va, confirmar que RLS devuelve un resultado vacío - no los datos de otro tenant y no un error - para ese ex-miembro que pega a los endpoints de notifications / coverage / traceability del workspace. Un resultado vacío por sí solo no es prueba; debe ir acompañado del caso positivo (un miembro todavía válido ve sus datos) en la misma corrida.
- **§3.3 PAT Scope Enforcement (rank: CRITICAL).** `DELETE /workspaces/{id}/membership` es una de las 4 rutas Cookie-only que un llamador bearer/PAT nunca debe alcanzar - re-verificar que un token es rechazado en esta ruta, distinto de las rutas de nivel Dual.
- **§4.3 gap de descubrimiento.** El endpoint de transición `active <-> suspended` nunca fue localizado en ninguna pasada de mapas - tratar cualquier transición de member-status que no sea "leave" como solo a nivel schema (CHECK + RLS), no como una ruta confirmada.

## Fuentes usadas

- `story.md`, `acceptance-criteria.md`, `scope.md`, `out-of-scope.md` (esta carpeta)
- `.context/business/business-data-map.md` - §2 mapa de entidades, §3.1 bootstrap, §3.12 PAT, §4.4 Workspace Member Status
- `.context/business/business-feature-map.md` - FEAT-012, FEAT-005/006/008/010/011/013, matriz CRUD, catálogo de endpoints, nota de auth-tier
- `.context/business/business-api-map.md` - §2 modelo de permisos y auth (nivel Cookie-only), §3.7 tenant isolation
- `.context/business/domain-glossary.md` - §1.1 / §1.2, enums de role y status, BR-8, §5 mapas de términos, §6.4 máquina de estados
- `.context/master-test-plan.md` - §3.1, §3.3, §4.3, tabla de riesgos, ítems de checklist 12 y el caso de orden de sole-owner

## Zonas donde los mapas quedaron en silencio (marcadas, no inventadas)

- Shape del body de request/response y status code de éxito para `DELETE /workspaces/{id}/membership`.
- Qué workspace pasa a estar "activo" después de que un usuario deja el que estaba viendo (la regla de resolución).
- Si un PAT con scope de workspace que tenga el usuario que se va se auto-revoca como parte del leave.
- Si la fila de membership se borra hard o se retiene de algún modo al irse (los mapas dicen "removed"/terminal, sin detalle de mecanismo).
- Cualquier UX de co-owner que se va - los mapas cubren BR-8 solo a nivel RPC/schema.

> Las primeras 4 quedaron respondidas por el reconocimiento del 2026-09-08 (source del RPC + contrato de API). Las respuestas están en `reconocimiento-hallazgos-SELLADO.md`, que NO se abre hasta terminar la pasada ciega, para no masticar los edge cases.

## Excluido deliberadamente

Sin plan de implementación, sin acceptance test plan, sin defectos históricos, sin tickets de bug vinculados, sin el resultado real de resolución de BK-90 / BK-859. Este es el lado ciego de un ejercicio de entrenamiento ciego-vs-asistido.
