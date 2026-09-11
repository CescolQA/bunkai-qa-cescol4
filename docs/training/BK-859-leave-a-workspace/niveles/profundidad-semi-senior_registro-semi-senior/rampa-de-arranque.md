# BK-859 - Rampa de arranque (orientación + reconocimiento de tooling)

> Checklist de acción para los primeros 10-15 minutos: ubicarme en la app y dejar el entorno listo para explorar "Leave a workspace". NO es diseño de pruebas.
> Complemento de `business-context-brief.md` (referencia). Este se sigue y se tilda.
>
> Estado: **corrida in-app completada** (2026-09-08, read-only staging). Login resuelto con cuenta nueva. Detalle de implementación (RPC, contrato) en `reconocimiento-hallazgos-SELLADO.md`, sellado hasta terminar la pasada ciega.

---

## 0. Antes de tocar nada

- [x] Ticket correcto: **BK-859**, clon de práctica de BK-90, Epic BK-85, Sprint 4, Ready For QA.
- [ ] NO abrir todavía: `implementation-plan.md`, `acceptance-test-plan.md`, `reconocimiento-hallazgos-SELLADO.md`, ni la resolución real de BK-90. Rompen la pasada ciega.

## 1. Entorno

| Dato | Valor | Estado |
|---|---|---|
| Entorno | `staging` | `.agents/project.yaml` (`default_env: staging`) |
| Web URL | `https://staging-upexbunkai.vercel.app` | confirmada |
| API base | `https://staging-upexbunkai.vercel.app/api` | endpoints `/api/v1/*` presentes |
| Usuario de prueba | `usuariobunkai3@dreniadxii.resend.app` / `STAGING_USER_PASSWORD` (`.env`) | **OK - login verificado** |
| DB | MCP `dbhub`, rol `qa_inspector_rw` (SELECT + DELETE en `public.workspaces` / `workspace_members`; `auth` denegado) | OK (lectura) |

### Historial del bloqueo (resuelto)

- El usuario viejo (`usuariobunkai1@...`) daba `401 {"code":"unauthorized","message":"Invalid email or password."}` en `POST /api/v1/auth/signin`. Verificado a mano en Chrome, no era artefacto de tooling: la password de `.env` no matcheaba esa cuenta en staging.
- La app **no tiene reset de password self-service** (no hay "Forgot password" en el login; solo magic-link, GitHub, Google).
- Resuelto: se creó una cuenta nueva desde la app (`usuariobunkai3@...`) con password elegida, y se actualizó `.env`. `signin` ahora da **200**, redirige a `/projects`.

## 2. Mapa de navegación real (verificado en la app)

| Cosa | Ruta / control real |
|---|---|
| Landing post-login | `/projects` |
| Lista de workspaces | `/settings/workspaces` (ruta directa, no redirige) |
| Sub-nav de Settings | Account · Tokens · **Workspaces** · Notifications · Billing · Data export |
| Identidad + workspace activo | `GET /api/v1/me` -> `{ user:{id,email}, workspaces[], active_workspace_id, active_workspace_role, auth:{source,scopes} }` |
| Lista de workspaces (API) | `GET /api/v1/workspaces` -> `{ workspaces:[{id,slug,name,owner_user_id,plan,created_at,role}] }` |
| Switcher de workspace (topbar) | botón "B3 Bunkai 3"; el dropdown solo lista los workspaces, **sin opción de crear** |

### Capacidades a nivel endpoint (de la superficie de API en staging)

| Acción | Endpoint | ¿Está? |
|---|---|---|
| Crear workspace | `POST /api/v1/workspaces` | sí (API). **Sin UI visible** para un usuario existente (ver seccion 3) |
| Dejar workspace | `DELETE /api/v1/workspaces/{id}/membership` | sí, cookie-only (PAT -> 403) |
| Borrar workspace | `DELETE /api/v1/workspaces/{id}` | sí. Botón "Delete" visible en `/settings/workspaces`. *El brief decía que no existía* |
| Restaurar workspace | `POST /api/v1/workspaces/{id}/restore` | sí |
| Editar workspace | `PATCH /api/v1/workspaces/{id}` | sí, owner-only, hoy solo `name` |
| Gestionar invites | `GET/POST /api/v1/workspaces/{id}/invites`, `.../invites/{inviteId}` | sí |
| Transferir ownership | - | no está |
| Cambiar role/status de miembro (`active<->suspended`, promover co-owner) | - | no está |
| Setear active workspace | `POST /api/v1/me/active-workspace` | sí, dual-auth, cookie `bk_active_ws` |

## 3. Estado actual del usuario de prueba

De `GET /api/v1/me` y `GET /api/v1/workspaces`:

| Dato | Valor |
|---|---|
| `user_id` | `3404d3e6-e14e-4978-b633-907c05e92d9a` |
| email | `usuariobunkai3@dreniadxii.resend.app` |
| Workspaces | 1: **Bunkai 3** (`bunkai-3`, id `00d9567f-7c44-4017-af01-99bc749e6d0b`), plan `community`, role `owner`, 1 member |
| Active workspace | Bunkai 3 |
| Clasificación | **sole owner Y única membresía** -> ambos guards (`last_membership` + `sole_owner`) aplican sobre este workspace |

### Qué muestra la UI hoy (sole owner + único workspace)

- En `/settings/workspaces`, la card de Bunkai 3 ofrece **"Delete"**, NO "Leave".
- El control de Leave **no se renderiza** en este escenario. Coincide con la lógica de guards (la acción no se ofrece cuando no se puede ejecutar).

### Fixtures que faltan para probar Leave de verdad

No hay UI de creación de workspace para un usuario existente -> se arman por API.

| Escenario | Cómo armarlo | Para qué |
|---|---|---|
| 2do workspace (quedo con >=2) | `POST /api/v1/workspaces` | desbloquea el guard `last_membership` |
| Co-owner | 2do workspace + invitar a otro user como `owner` (`POST .../invites`) o al revés | esperar que Leave funcione |
| Member no-owner | ser invitado a un workspace ajeno como `member`/`viewer` | camino sin guard de owner |
| Sole owner (ya lo tengo) | Bunkai 3 tal cual | esperar bloqueo `sole_owner` (409) |
| Única membresía (ya lo tengo) | Bunkai 3 mientras sea el único | esperar bloqueo `last_membership` (409) |

Nota de datos de staging: co-owner y member-simple son raros en la instancia (~21 filas activas no-owner en total). Hay que construirlos.

### Crear un workspace (por API, `POST /api/v1/workspaces`)

- Body (ambos requeridos): `name` string 1-80; `slug` string 3-40, regex `^[a-z0-9][a-z0-9-]{1,38}[a-z0-9]$`.
- 16 slugs reservados -> 422: `admin api app auth docs invites login logout onboarding projects public qa settings static workspaces _next`.
- slug tomado -> 409. Éxito -> 201 `{ workspace: {...} }`.

## 4. Checkpoints "estoy ubicado"

- [x] Login OK, landing en `/projects`.
- [x] Veo la lista de workspaces en `/settings/workspaces` con rol (`owner`).
- [x] Sé mi `user_id` de staging (`3404d3e6-...`, de `GET /api/v1/me`).
- [x] En el workspace donde soy sole owner + única membresía, NO hay Leave; hay Delete.
- [ ] Ver el `LeaveWorkspaceModal` real (pendiente: requiere fixture con 2do workspace / co-owner).
- [ ] Confirmar si el modal nombra el workspace y cuáles son los labels de confirm/cancel.

## 5. Verificación en DB (lectura)

`auth` no es accesible para `qa_inspector_rw`; el `user_id` ya lo tenemos de `GET /api/v1/me`.

```sql
-- mis membresías
select workspace_id, role, status, joined_at
from public.workspace_members
where user_id = '3404d3e6-e14e-4978-b633-907c05e92d9a'
order by joined_at;

-- owners activos por workspace
select workspace_id,
       count(*) filter (where role = 'owner' and status = 'active') as active_owners
from public.workspace_members
where workspace_id = '00d9567f-7c44-4017-af01-99bc749e6d0b'
group by workspace_id;
```

## 6. Evidencia

- `evidence/recon-01-login.png` - login page (cuenta vieja)
- `evidence/recon-02-login-failed.png` - 401 con cuenta vieja
- `evidence/recon-03-logged-in-projects.png` - post-login OK, `/projects` (cuenta nueva)
- `evidence/recon-04-settings-workspaces.png` - `/settings/workspaces`, card de Bunkai 3 con "Delete"
- `evidence/recon-05-settings-workspaces-loggedin.png` - idem, recarga

## 7. Notas y anomalías de la corrida

- **Login**: cuenta vieja `usuariobunkai1` tenía password desincronizada en staging. Cuenta nueva `usuariobunkai3` creada desde la app, `.env` actualizado, login 200.
- **No hay reset de password self-service** en la app (sin "Forgot password"). Recuperación de acceso = magic-link, OAuth, o crear cuenta nueva.
- **No hay UI de creación de workspace** para un usuario existente (ni en `/settings/workspaces` ni en el switcher). Creación = onboarding o API (`POST /api/v1/workspaces`).
- **Brief vs realidad**: borrar workspace está shippeado (botón "Delete" visible). Ya corregido en el brief.
- **status enum**: real es `active | invited | suspended` (brief listaba `active | suspended`). Corregido.
- **Leave no se renderiza** cuando los guards aplican: en sole-owner + única membresía la UI muestra Delete, no Leave.
- Detalle de RPC y contrato de error: en `reconocimiento-hallazgos-SELLADO.md` (no abrir antes de la pasada ciega).
