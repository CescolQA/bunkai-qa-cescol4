# Ejecución — tanda ejecutable con fixtures A + B

> Paso 6 parcial. Se ejecutó solo lo que el estado actual de fixtures permite (A y B montados; C y D en standby).
> Entorno: **staging** (`https://staging-upexbunkai.vercel.app`). Cuenta: `usuariobunkai3@dreniadxii.resend.app`.
> Fecha: 2026-09-10. IDs de caso según `06d-matriz-de-casos-v4.md`.

---

## Estado de fixtures al momento de ejecutar

La cuenta tiene **2 membresías activas**, y es **sole owner de las dos**:

| Workspace | id | role | status | joined_at |
|---|---|---|---|---|
| `bunkai-3` | `00d9567f-7c44-4017-af01-99bc749e6d0b` | owner | active | 2026-09-08 17:04 |
| `fixture-b-bk859` | `7a14b2d9-24fa-481b-821d-50da6ca01491` | owner | active | 2026-09-10 13:14 |

**Consecuencia para el diseño:** al crear el fixture B, la cuenta dejó de estar en estado "única membresía". Los casos que dependen de ese estado (`TC-09`, `TC-10`, `TC-11`) **no son ejecutables ahora** sin volver a 1 membresía (borrar fixture B, o usar una 2da cuenta).

---

## Resultados

| ID | Naturaleza | Resultado | Detalle |
|---|---|---|---|
| **TC-18** | Contrato | ✅ PASS | `DELETE /api/v1/workspaces/{id}/membership` sin auth → `401`. Body: `{"error":{"code":"unauthorized","message":"Authentication required."}}` |
| **TC-19** | Contrato | ✅ PASS | Con `Authorization: Bearer <PAT>` y sin cookie → `403`. Body: `{"error":{"code":"forbidden","message":"Personal access tokens cannot leave a workspace. Use a browser session."}}`. Confirma la ruta cookie-only de la recon |
| **TC-20** | Contrato | ✅ PASS | Con cookie válida, UUID inexistente (`00000000-0000-4000-8000-000000000000`) → `404`. Body: `{"error":{"code":"not_found","message":"Workspace not found or you are not an active member."}}` |
| **TC-21** | Contrato | ✅ PASS | Con cookie válida, workspace REAL donde la cuenta no es miembro (`02efd349-...`) → `404`. **Mismo `code` y mismo `message` que TC-20** |
| **TC-06** | Bloqueo | ✅ PASS | Con cookie válida, `DELETE` sobre `fixture-b-bk859` (sole owner, 2 membresías) → `409`. Body: `{"error":{"code":"conflict","message":"You are the only owner of this workspace. Transfer ownership before leaving.","details":{"reason":"sole_owner"}}}`. DB post-intento: la fila sigue `owner` / `active`. Nada se borró |
| **TC-07** | Bloqueo | ✅ PASS | En `/settings/workspaces`, ambas filas muestran badge **"Can't leave"** + copy **"You're its only owner. Ownership transfer isn't available yet."**. No hay botón "Leave"; sí hay botón "Delete". Coincide con AC S2 y con el mockup. Evidencia: `../evidence/tc07-sole-owner-cant-leave.png` |

**6 casos ejecutados, 6 PASS.**

---

## Hallazgos de la ejecución

### H-EJEC-1 — El `409` sí trae un discriminador legible por máquina

El error de `sole_owner` viene con `details.reason: "sole_owner"`, no solo con texto libre en `message`. Esto **suaviza** el *improvement candidate* de `07` (H1): el `code` genérico es `conflict`, pero `details.reason` distingue el motivo.

Falta confirmar la simetría: que el `409` de `last_membership` emita `details.reason: "last_membership"`. Eso queda en standby hasta tener el fixture de 1 membresía. Recién ahí `TC-08` se puede cerrar.

### H-EJEC-2 — `404` no distingue "no existe" de "no sos miembro"

`TC-20` y `TC-21` devuelven exactamente el mismo `code` (`not_found`) y el mismo `message` ("Workspace not found or you are not an active member."). Es una decisión de seguridad razonable: no filtrar a un no-miembro si un workspace existe o no. Se registra como **observación**, no como bug.

### H-EJEC-3 — Scopes del PAT de signin

El PAT que devuelve `POST /api/v1/auth/signin` trae scopes `atc:read`, `atc:write`, `run:execute` (sin `workspace:admin`). Coincide con la recon.

---

## Standby (no ejecutable con el estado actual)

| Casos | Qué falta |
|---|---|
| `TC-09`, `TC-10`, `TC-11` | Cuenta con **1 sola membresía** (borrar fixture B, o 2da cuenta) |
| `TC-08` (cierre) | Lo anterior, para comparar el `details.reason` de los dos `409` |
| `TC-01`, `TC-02`, `TC-03`, `TC-04`, `TC-05`, `TC-15` | Fixture **D** (member invitado) o **C** (co-owner) para un leave que sí se completa |
| `TC-12`, `TC-13`, `TC-14` | Fixture **D** + contenido autorado + PATs con scope |
| `TC-16`, `TC-17` | Fixture **C** (2 owners) / D variante `admin` |
| `TC-24` | Un leave exitoso previo (necesita D) |
| `TC-25`, `TC-27` | P3: empate de `joined_at` / race de co-owners |
| `TC-26` | Acceso a la ruta de IA agéntica con credenciales de prueba (a confirmar) |

---

## Ronda 2 — 2026-09-10, tras borrar `bunkai-3`

César borró el workspace `bunkai-3` desde la UI (`DELETE /api/v1/workspaces/{id}`), buscando dejar la cuenta con 1 sola membresía para poder correr `TC-09` / `TC-10` / `TC-11`.

### Lo que se ve en la API vs lo que ve el RPC

| Fuente | Membresías activas que reporta |
|---|---|
| `GET /api/v1/workspaces` | **1** (`fixture-b-bk859`) — filtra los workspaces con `deleted_at` |
| RPC `bunkai_leave_workspace` (guard 3) | **2** — cuenta `workspace_members WHERE status='active'`, sin mirar `workspaces.deleted_at` |

En DB: la fila de membresía de `bunkai-3` **sigue `status='active'`** aunque el workspace tiene `deleted_at = 2026-09-10T19:06`. El borrado de workspace es soft-delete y **no toca las membresías**.

### Resultado del intento TC-09 / TC-11

`DELETE /api/v1/workspaces/7a14b2d9.../membership` con la cuenta "de 1 workspace visible" → `409` con `details.reason: "sole_owner"` y mensaje `"You are the only owner of this workspace. Transfer ownership before leaving."`

No es `last_membership`. Y es correcto **dado que el RPC ve 2 membresías activas**: guard 3 (`<= 1`) no dispara, guard 4 (`sole_owner`) sí. O sea: `TC-09` y `TC-11` **siguen sin poder aislarse** — este intento fue, en la práctica, un `TC-06` repetido sobre otro workspace.

### 🐞 Hallazgo DEF-1 — el soft-delete de workspace no limpia las membresías, y eso rompe el guard `last_membership`

**Qué:** al borrar un workspace (`DELETE /api/v1/workspaces/{id}`, soft-delete de BK-512), la fila de `workspace_members` del dueño queda `status='active'`. El RPC de "leave" cuenta esas filas sin excluir workspaces borrados (`bunkai_leave_workspace` no hace join con `workspaces` ni filtra `deleted_at`).

**Por qué es un problema:**
1. **Se puede dejar a la cuenta sin ningún workspace vivo.** Un usuario con 1 workspace vivo (como `member`, no owner) + 1 workspace borrado (membresía todavía `active`) tiene conteo = 2. Guard 3 pasa, guard 4 no aplica (no es owner) → el leave **se completa** y el usuario queda con **0 membresías a workspaces vivos**. Es exactamente el "strand the account" que el Escenario A existe para evitar.
2. **El mensaje de error es el equivocado.** Un usuario parado en su único workspace *vivo* debería ver `"You cannot leave your only workspace."` (copy del Escenario A). En su lugar ve `"You are the only owner..."` (copy del Escenario 2), porque el guard que se dispara es el de sole owner.

**Clasificación (borrador):** Defect (ambas features — BK-512 delete y BK-859 leave — están pre-release). Vive en el límite entre las dos historias: el delete no cascadea a las membresías, y el guard del leave no excluye workspaces borrados. Severidad moderada-a-mayor (puede dejar una cuenta sin acceso), con precondición específica (haber borrado un workspace del que se es miembro).

**Relación:** misma clase que el hallazgo H8 de la recon (15 workspaces con 0 owners activos en staging = estado de membresías inconsistente con el ciclo de vida del workspace).

### DEF-1 — chequeo contra la especificación de BK-512 (delete a workspace)

César preguntó si esto ya está resuelto o si las definiciones no coinciden. Se revisó BK-512.

**El spec de BK-512 respalda el hallazgo.** `acceptance-criteria.md` AC-07 dice, al confirmar el delete: *"its memberships, pending invites, Personal Access Tokens and Notifications **stop working at that same instant**"*. O sea: la membresía a un workspace borrado **no debe contar como membresía viva**. Las filas se retienen solo para el restore de 30 días (ADR-0015), no para conferir acceso ni para contar.

**Causa raíz — regresión entre historias.** La migración `0044_leave_workspace.sql` fue escrita el **2026-07-31**. El modelo de soft-delete + 30 días + restore de BK-512 se decidió **después** (ADR-0015 + fallo del 2026-08-29). El guard `last_membership` de `0044` cuenta `workspace_members WHERE status='active'` sin excluir `workspaces.deleted_at` — era correcto cuando borrar un workspace implicaba que sus membresías desaparecían. El soft-delete de BK-512 rompió ese supuesto y nadie volvió a ajustar el guard.

**No está resuelto en el punto de unión.** ADR-0015 y los fallos resolvieron el modelo de gracia/restore *de BK-512*. Ni BK-512 ni BK-859 tienen un AC que cubra "el guard de leave excluye membresías de workspaces borrados". Es un hueco en la costura entre las dos historias.

Nota: BK-512 AC-10 confirma que delete y leave difieren a propósito (borrar tu único workspace → onboarding; dejar tu único workspace → bloqueado). DEF-1 no contradice eso: es sobre el **conteo** que hace el guard de leave, no sobre la política.

### 🐞 DEF-2 — el campo "Business Rules" de BK-512 está desactualizado

`business-rules.md` de BK-512 todavía dice: *"The deletion is immediate and irreversible. There is no grace period, no recoverable state and no restore. The confirmation must say so in those terms."*

Contradice a: AC-03, AC-07, la nota de resolución de los "New Scenarios" (*"soft-delete with a 30-day grace period, access revoked immediately"* — consistente con **ADR-0015**), y el diálogo que ya está en staging (*"restored... before that 30-day deadline"*). El campo nunca se actualizó tras el fallo del 2026-08-29.

**Clasificación:** defecto de documentación. Misma clase que el comentario de shift-left que ya se posteó en BK-859 (reglas de negocio sin consolidar / desincronizadas de las ACs).

### `TC-08` — resuelto por inspección de código

No se pudo observar un `409` de `last_membership` en vivo (haría falta una cuenta con 1 membresía activa *real*, sin membresías a workspaces borrados). Pero el handler (`app/api/v1/workspaces/[id]/membership/response.ts`, `mapLeaveWorkspaceError`) **sí distingue los dos motivos**, en los dos ejes:

| SQLSTATE | `details.reason` | `message` |
|---|---|---|
| `45212` | `last_membership` | `You cannot leave your only workspace.` |
| `45213` | `sole_owner` | `You are the only owner of this workspace. Transfer ownership before leaving.` |

**`TC-08` = PASS por código** (pendiente confirmación en vivo del branch `last_membership`). El *improvement candidate* de `07` (H1: "los dos 409 no se distinguen") queda **descartado**: se distinguen por `details.reason` y por `message`. El `code` genérico `conflict` es la envoltura de la casa, no el discriminador.

### Standby revisado

| Casos | Qué falta ahora |
|---|---|
| `TC-09`, `TC-10`, `TC-11` | Una cuenta con **1 membresía activa real** (sin filas `active` a workspaces `deleted_at`). Opciones: limpiar la fila de `bunkai-3` en DB, o una cuenta nueva. Ojo: limpiarla en DB taparía DEF-1 |
| `TC-01`..`TC-05`, `TC-12`..`TC-17`, `TC-24` | Fixtures **C** (co-owner) / **D** (member invitado) para un leave que se completa |
| `TC-25`, `TC-27` | P3 |
| `TC-26` | Acceso a la ruta de IA agéntica |

---

## Próximo

Insumo para el **paso 7** (comparativa): 6 casos PASS de la ronda 1 + `TC-08` PASS por código + **DEF-1** (hallazgo de exploración, ninguna de las dos pasadas de diseño lo previó — ni la ciega ni la asistida; salió de tocar la app). El resto se completa con los fixtures C y D.
