# Story 3 · UI + DB + API · BK-859

> Vigente al 2026-11-25. Registro de ejecución: [`08-ejecucion-fixtures-A-B.md`](../../docs/training/BK-859-leave-a-workspace/niveles/profundidad-semi-senior_registro-semi-senior/pasada-asistida/08-ejecucion-fixtures-A-B.md). Matriz de 28 casos: [`06d-matriz-de-casos-v4.md`](../../docs/training/BK-859-leave-a-workspace/niveles/profundidad-semi-senior_registro-semi-senior/pasada-asistida/06d-matriz-de-casos-v4.md).

## La historia

**BK-859** · TMS-Workspace: dejar un workspace. Una persona puede salir de un workspace, salvo que sea su única membresía o la única dueña.

| Punto | Resultado |
|---|---|
| Ambiente | staging |
| Resultado | 7 casos PASS + 1 defecto propio |
| Cierre | Blocked por el defecto BK-1901 (abierto) |
| Artefactos | ATP BK-860 (Completed) · ATR BK-861 (Close) · Defect BK-1901 · Improvement BK-1902 |

## Qué cubre cada capa

| Capa | Caso | Qué se verificó | Resultado |
|---|---|---|---|
| API | TC-18 | `DELETE /api/v1/workspaces/{id}/membership` sin autenticación → `401` | PASS |
| API | TC-19 | con token personal (PAT) y sin cookie → `403` "Personal access tokens cannot leave a workspace" | PASS |
| API | TC-20 | workspace inexistente → `404` | PASS |
| API | TC-21 | workspace real del que no es miembro → `404` con el mismo código y mensaje que TC-20 | PASS |
| API + DB | TC-06 | única dueña con 2 membresías → `409` `details.reason: "sole_owner"`; en la base, la fila sigue `owner` / `active` | PASS |
| UI | TC-07 | `/settings/workspaces` muestra "Can't leave" y el texto de única dueña, sin botón Leave | PASS |
| Código | TC-08 | los dos `409` se distinguen por `details.reason` y por mensaje | PASS por inspección de código |

## El defecto: BK-1901

- **Qué pasa:** al borrar un workspace (soft-delete), la membresía del dueño queda `status='active'`. La regla que impide dejar el último workspace cuenta esas filas sin excluir los workspaces borrados.
- **Consecuencia:** una cuenta puede quedarse sin ningún workspace vivo, y el mensaje de error que ve es el equivocado.
- **Cómo salió:** de explorar la app con los datos de prueba (fixtures); ninguna de las dos pasadas de diseño (manual y asistida) lo había previsto.
- **Contraste con la base:** API (`GET /api/v1/workspaces` ve 1 membresía) frente a la función de la base (`bunkai_leave_workspace` cuenta 2).
- **Confirmación:** Ely (AI Tech Lead) confirmó la causa en el código entregado y eligió la solución (migración `0128`).
- **Improvement BK-1902:** el campo de reglas de negocio de BK-512 contradice sus propios criterios (dice "sin período de gracia" y la app tiene 30 días de restauración).

## Decisiones que se pueden defender

| Decisión | Por qué |
|---|---|
| pasada ciega (sin IA) antes de la asistida | comparar el criterio propio con el asistido y medir qué aporta cada uno |
| fixture B armado a mano con Postman | práctica de API: `signin` → PAT → crear workspace |
| fixtures C y D fuera de alcance | decisión de alcance: el objetivo de la práctica quedó cubierto; 12 casos dependen de ellos |
| BK-1901 como Defect y no como Improvement | puede dejar una cuenta sin acceso; contradice el criterio AC-07 de BK-512 |
