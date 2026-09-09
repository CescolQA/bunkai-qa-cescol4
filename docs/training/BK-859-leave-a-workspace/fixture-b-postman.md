# BK-859 - Fixture B a mano con Postman (repaso de API)

> Paso 6 de la práctica. Objetivo doble: (a) dejar montado el **fixture B**, (b) que vos
> vuelvas a hacer configuración y llamados de API a mano antes de que la IA los scripte.
> Idioma castellano. Rutas, nombres de campo, headers y códigos van textuales.
> Contrato leído del OpenAPI de staging el 2026-09-09. Si algo no coincide al ejecutarlo,
> anotalo: el contrato pudo cambiar.

---

## 1. Qué es el fixture B y para qué sirve

Hoy tu usuario en staging está en el estado del **fixture A**: es `owner` único de un solo
workspace (Bunkai 3), y es su única membresía activa. Si intenta "leave", lo frenan **dos**
guards a la vez: `last_membership` (`45212`) y `sole_owner` (`45213`).

El fixture B agrega **un segundo workspace propio**. Después de eso:

| Antes (fixture A) | Después (fixture B) |
|---|---|
| 1 membresía activa | 2 membresías activas |
| "leave" frenado por `last_membership` Y `sole_owner` juntos | `last_membership` ya **no** aplica; queda solo `sole_owner` |

Para qué sirve en las pruebas: aísla un guard del otro. Con fixture B podés provocar un
`409` que sea **solo** `sole_owner` (`45213`) y verificar que el sistema lo distingue del
`last_membership` (`45212`).

## 2. Hallazgo que cambia el plan: acá SÍ podés usar un PAT

El plan viejo (en el README) asumía que había que sacar la cookie de sesión del navegador.
**No hace falta.** El contrato dice:

- `POST /api/v1/workspaces` (crear workspace) acepta **dos** formas de auth: `cookieAuth`
  **o** `bearerAuth`. O sea, un PAT (token Bearer) sirve.
- Solo la operación "leave" (`DELETE /api/v1/workspaces/{id}/membership`) es cookie-only.
  Crear no lo es.
- Y hay un endpoint headless para conseguir el PAT sin navegador:
  `POST /api/v1/auth/signin` te devuelve un PAT recién emitido en la misma respuesta.

Traducción: **email + password → PAT → creás el workspace con ese PAT.** Todo desde Postman,
sin tocar cookies.

Recordatorio de términos (detalle en `../bunkai-capas-e-integraciones-para-qa.md`):

- **PAT**: token que un programa manda en el header `Authorization: Bearer <token>`.
- **Bearer**: la forma de mandar ese token en un header HTTP.

## 3. Lo que vas a usar

| Cosa | Valor |
|---|---|
| Herramienta | Postman |
| Entorno | staging |
| Base URL | `https://staging-upexbunkai.vercel.app` |
| Credenciales | `STAGING_USER_EMAIL` y `STAGING_USER_PASSWORD` del archivo `.env` (no las pegues en el doc ni en la colección compartida) |
| Verificación en DB (opcional) | DBHub o el cliente MySQL de VS Code, contra el pooler de Supabase de staging |

## 4. Preparar Postman (una vez)

1. Creá un **Environment** llamado `bunkai-staging` con estas variables:

   | Variable | Initial value | Notas |
   |---|---|---|
   | `baseUrl` | `https://staging-upexbunkai.vercel.app` | |
   | `email` | (tu `STAGING_USER_EMAIL`) | marcala como *secret* |
   | `password` | (tu `STAGING_USER_PASSWORD`) | marcala como *secret* |
   | `pat` | (vacío) | lo llena el paso 5 |
   | `wsId` | (vacío) | lo llena el paso 6 |

2. Creá una **Collection** `BK-859 fixture B` con 3 requests (pasos 5, 6, 7).
3. En cada request, seleccioná el environment `bunkai-staging` arriba a la derecha.

## 5. Request 1 - Sign-in headless (conseguir el PAT)

| Campo | Valor |
|---|---|
| Método | `POST` |
| URL | `{{baseUrl}}/api/v1/auth/signin` |
| Header | `Content-Type: application/json` |
| Body (raw, JSON) | ver abajo |

```json
{
  "email": "{{email}}",
  "password": "{{password}}"
}
```

Campos opcionales del body (no los necesitás ahora): `pat_name`, `pat_scopes`,
`pat_expires_in_days`. Si NO mandás `pat_scopes`, el PAT sale con los scopes por defecto
`atc:read`, `atc:write`, `run:execute`. **No** mandes `workspace:admin` en `pat_scopes`:
devuelve `403`.

### Respuesta esperada: `200`

Forma resumida:

```json
{
  "user":    { "id": "…", "email": "…" },
  "session": { "access_token": "…", "refresh_token": "…", "expires_at": 0, "token_type": "…" },
  "pat":     { "token": "ESTE es el que te importa", "id": "…", "name": null, "scopes": [ … ], "expires_at": "…" },
  "warning": "…"
}
```

### Guardar el PAT automáticamente

En la pestaña **Scripts → Post-response** del request, pegá:

```javascript
const body = pm.response.json();
pm.environment.set("pat", body.pat.token);
```

Así `{{pat}}` queda listo para el paso 6.

### Otros códigos

| Código | Qué significa | Qué hacer |
|---|---|---|
| `401` | Credenciales inválidas | La `STAGING_USER_PASSWORD` de `.env` está vencida. Reseteala desde la app logueándote en el navegador, actualizá `.env`, reintentá |
| `422` | El body no pasó validación | Revisá que `email` tenga formato de mail y `password` tenga entre 6 y 128 caracteres |

## 6. Request 2 - Crear el segundo workspace

| Campo | Valor |
|---|---|
| Método | `POST` |
| URL | `{{baseUrl}}/api/v1/workspaces` |
| Header | `Content-Type: application/json` |
| Header | `Authorization: Bearer {{pat}}` |
| Body (raw, JSON) | ver abajo |

```json
{
  "name": "Fixture B BK-859",
  "slug": "fixture-b-bk859"
}
```

### Reglas del `slug` (importante)

| Regla | Detalle |
|---|---|
| Formato | regex `^[a-z0-9][a-z0-9-]{1,38}[a-z0-9]$` |
| En palabras | solo minúsculas, dígitos y guiones. Entre 3 y 40 caracteres. Sin guion al principio ni al final. Nada de mayúsculas, guion bajo, espacios |
| Reservados (16) | `admin`, `api`, `app`, `auth`, `docs`, `invites`, `login`, `logout`, `onboarding`, `projects`, `public`, `qa`, `settings`, `static`, `workspaces`, `_next` → devuelven `422` |
| Ya usado | si otro workspace tiene ese slug → `409` |

El `name` es libre, entre 1 y 80 caracteres.

### Respuesta esperada: `201`

```json
{
  "workspace": { "id": "…", "slug": "fixture-b-bk859", "name": "Fixture B BK-859", "…": "…" }
}
```

### Guardar el id del workspace

En **Scripts → Post-response**:

```javascript
const body = pm.response.json();
pm.environment.set("wsId", body.workspace.id);
```

Anotá también ese `wsId` en la sección 9 de este doc, para el teardown.

### Otros códigos

| Código | Qué significa |
|---|---|
| `401` | El header `Authorization: Bearer {{pat}}` falta o el PAT no sirve. Reejecutá el paso 5 |
| `409` | El `slug` ya está tomado. Cambialo y reintentá |
| `422` | El `slug` rompe el formato o es uno de los 16 reservados |

## 7. Request 3 - Verificar

### 7.1 Por API

| Campo | Valor |
|---|---|
| Método | `GET` |
| URL | `{{baseUrl}}/api/v1/workspaces` |
| Header | `Authorization: Bearer {{pat}}` |

Esperado: `200` con una lista que ahora tiene **2** workspaces (Bunkai 3 + el nuevo).

### 7.2 Por la app

Logueado en el navegador: `Settings > Workspaces`. Deberían aparecer los 2.

### 7.3 Por base de datos (opcional)

```sql
select workspace_id, role, status, joined_at
from public.workspace_members
where user_id = '<tu user_id, del campo user.id del paso 5>'
order by joined_at;
```

Esperado: 2 filas, ambas `role = 'owner'`, `status = 'active'`.

## 8. Teardown (dejar limpio)

`DELETE /api/v1/workspaces/{id}` **es cookie-only**: el PAT no puede borrarlo. Opciones,
de menos a más intrusiva:

1. **Dejarlo.** Para la práctica no molesta tener un workspace extra. Anotá el `wsId` y
   seguís.
2. **Borrarlo desde el navegador** logueado: `Settings > Workspaces > Delete` en el
   workspace nuevo. Es un borrado suave con 30 días de gracia.
3. **Por DB**, solo si sabés lo que hacés y tenés permiso de escritura.

Para BK-859 alcanza la opción 1 hasta terminar la práctica.

## 9. Registro de lo creado (completá vos)

| Dato | Valor |
|---|---|
| Fecha de creación | |
| `workspace.id` (`wsId`) | |
| `slug` usado | |
| `pat.id` (para revocarlo después si querés) | |
| Estado del teardown | pendiente / hecho |

## 10. Checklist

- [ ] Environment `bunkai-staging` creado con las 5 variables
- [ ] Paso 5: sign-in `200`, `{{pat}}` guardado
- [ ] Paso 6: create `201`, `{{wsId}}` guardado y anotado en la sección 9
- [ ] Paso 7: `GET /api/v1/workspaces` muestra 2 workspaces
- [ ] Anotadas las dudas o diferencias con el contrato

## 11. Dudas / notas (para la charla post)

_(escribí acá lo que no cerró: cualquier campo de respuesta que no entendiste, cualquier
código distinto al esperado, cualquier paso de Postman que costó)_
