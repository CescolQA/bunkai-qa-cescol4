# BK-859 - Hallazgos de reconocimiento - Documento 2 (lenguaje simple)

> Segunda versión del documento de hallazgos, reescrita en lenguaje más llano para
> **comparar** con `reconocimiento-hallazgos-SELLADO.md`.
> Mismo contenido, misma información técnica. Cambia solo cómo está explicado: se define
> cada término la primera vez y se agrega contexto.
> Identificadores, nombres de tablas y columnas, enums, rutas de endpoint, nombres de RPC
> y códigos SQLSTATE van textuales (no se traducen).
> Si algo de acá no se entiende, es un problema del documento, no tuyo. Marcalo.

---

## 0. Cómo leer este documento

Tres términos que se repiten. Si querés el panorama completo de capas, está en
`docs/training/bunkai-capas-e-integraciones-para-qa.md`.

- **RPC**: una función guardada dentro de la base de datos, con nombre propio, que la capa
  de API llama para hacer un trabajo. Acá se llama `bunkai_leave_workspace`.
- **Guard**: una condición que se chequea ANTES de permitir la acción. Si no se cumple, la
  operación se corta con error y no pasa nada más.
- **SQLSTATE**: un código corto (por ejemplo `45212`) que Postgres usa para nombrar un error
  puntual. Sirve para que la capa de API sepa exactamente qué falló.

## 1. La investigación: qué se miró y cómo

| Aspecto | Detalle |
|---|---|
| Fecha | 2026-09-08 |
| Entorno | staging |
| Tipo | Solo lectura. No se escribió nada |
| Qué sí se pudo ver | La definición de la RPC (texto SQL completo) y el contrato de la API (schema OpenAPI) |
| Qué no se pudo ver | La aplicación en el navegador: la credencial de acceso estaba vencida |

Todo lo que sigue sale de leer código y contratos, no de usar la app.

## 2. La RPC `bunkai_leave_workspace`

### 2.1 Qué es y cómo está configurada

Es la función de base de datos que ejecuta el "dejar un workspace".

- Recibe un solo parámetro: `p_workspace_id` (el identificador del workspace que se quiere dejar).
- No devuelve datos (`RETURNS void`): solo hace el trabajo o corta con error.
- Corre como `SECURITY DEFINER`: se ejecuta con los permisos de quien la creó, no de quien
  la llama. Es un patrón normal en este proyecto para escrituras controladas.

### 2.2 Los 4 guards, en orden

La función chequea estas 4 condiciones, una tras otra. **La primera que falle corta todo.**

| Orden | Qué chequea | Error | SQLSTATE | En criollo |
|---|---|---|---|---|
| 1 | ¿Hay alguien logueado? (`auth.uid()` no es null) | `not_authenticated` | `42501` | "No sé quién sos" |
| 2 | ¿El que llama es miembro activo de ese workspace? (tiene fila con `status='active'`) | `not_a_member` | `P0002` | "No sos parte de este workspace" |
| 3 | ¿Le queda más de 1 membresía activa en total? (si tiene 1 o menos, falla) | `last_membership` | `45212` | "Es tu único workspace, no te podés quedar sin ninguno" |
| 4 | Si tu role es `owner`: ¿hay al menos otro `owner` activo? (si sos el único, falla) | `sole_owner` | `45213` | "Sos el único dueño; el workspace no puede quedar sin dueño" |

El orden importa. Ejemplo: si no sos miembro (guard 2 falla), nunca se llega a chequear si
sos el único owner (guard 4).

### 2.3 Qué hace cuando pasás los 4 guards

1. **Borra tu fila** de la tabla `public.workspace_members`. Es un *hard delete*: la fila
   desaparece de verdad. Distinto de marcarla `suspended`, que la conserva.
2. **Revoca tus PAT de ese workspace.** Un PAT (Personal Access Token) es un token que usa
   un programa para entrar a la API. Los que tenían alcance del workspace que dejaste quedan
   marcados como revocados (`revoked_at = now()`), en la misma operación.

### 2.4 Lo que la RPC NO hace

No cambia cuál es tu *active workspace* (el que tu sesión tiene seleccionado). Eso lo
resuelve la capa de API, no la base de datos. Ver punto 3.3.

## 3. El endpoint `DELETE /api/v1/workspaces/{id}/membership`

Es la ruta HTTP que la UI llama para disparar todo esto.

- Autenticación: **cookie-only**. Solo funciona con la cookie de sesión de una persona
  logueada. Un PAT NO puede usar esta ruta (es una de las 4 rutas del sistema donde el PAT
  está excluido a propósito).
- No lleva body (no se manda información en el cuerpo del pedido).

### 3.1 Respuestas posibles

| Código HTTP | Qué significa | Detalle |
|---|---|---|
| `200` | Salió bien | Devuelve `{ newActiveWorkspaceId, newActiveWorkspaceName }` (ambos campos siempre presentes). Si el workspace que dejaste era tu activo, acá viene el nuevo activo ya elegido, y la cookie `bk_active_ws` se actualiza en la misma respuesta |
| `401` | No estás autenticado | No había sesión válida |
| `403` | Estás usando un PAT | Los PAT no pueden dejar un workspace. Es el "cookie-only" de arriba |
| `404` | El workspace no existe, o no sos miembro activo | Junta dos casos: workspace inexistente y "no sos miembro" (el `not_a_member` de la RPC) |
| `409` | Conflicto con una regla de negocio | Es `last_membership` O `sole_owner` (guards 3 y 4) |

### 3.2 Un detalle fino sobre el `409`

Los dos casos distintos (`last_membership` y `sole_owner`) devuelven **el mismo `409`**.
La estructura de error (`ErrorEnvelope` = `{ error: { code, message, details?, request_id? } }`)
tiene un campo `code`, pero solo con valores genéricos (`conflict`, `forbidden`, `not_found`,
`unauthorized`...). No hay un `code` propio para cada guard.

Consecuencia para pruebas: para distinguir "me fui y era mi único workspace" de "soy el
único dueño", hay que mirar el texto de `message` o el campo `details`, no el `code`.

### 3.3 Cómo se elige el nuevo active workspace

Cuando dejás el workspace que tenías activo, la API elige como nuevo activo **la membresía
más vieja que te queda** (ordena por `joined_at` ascendente y toma la primera). Esta lógica
vive en la capa de API, no en la RPC.

## 4. Preguntas que el brief dejó abiertas y ahora tienen respuesta

| Pregunta abierta en el brief | Respuesta del reconocimiento |
|---|---|
| ¿Qué forma tienen el pedido y la respuesta, y cuál es el código de éxito? | Éxito = `200`. Respuesta = `{ newActiveWorkspaceId, newActiveWorkspaceName }`. El pedido no lleva body |
| ¿Qué workspace queda activo después de irse? | La membresía más vieja que te queda (`joined_at` más antiguo). Lo decide la API, no la RPC |
| ¿Se revoca un PAT con alcance del workspace que dejás? | Sí. Es el paso 2 de "qué hace la RPC". Solo los PAT de ese workspace |
| ¿La fila de membresía se borra o se conserva? | Se borra de verdad (hard delete). No se conserva |
| ¿Cómo es la experiencia de un co-owner que se va? | No se pudo ver en el navegador (credencial vencida). A nivel servidor: el guard 4 es por conteo, así que un co-owner con otro owner al lado pasa sin problema |

## 5. Cosas que el brief decía y el reconocimiento corrigió

| El brief decía | La realidad en staging |
|---|---|
| "No existe `DELETE /api/v1/workspaces/{id}`" (borrar el workspace entero) | **Sí existe.** Solo para owner, solo con sesión. Hace un borrado suave con 30 días de gracia y un `POST /api/v1/workspaces/{id}/restore` para recuperar. Avisa por mail a todos los miembros. Referencias: BK-512, ADR-0015 |
| El enum `status` es `active` o `suspended` | En realidad son 3: `active`, `invited`, `suspended` |
| Los SQLSTATE de los guards | Confirmados: `last_membership` = `45212`, `sole_owner` = `45213`. Y además: `not_authenticated` = `42501`, `not_a_member` = `P0002` |
| El schema no impide varios `owner` en un mismo workspace | Confirmado. No hay ninguna restricción de unicidad. El guard 4 es puro conteo |

## 6. Endpoints vecinos que existen en staging

Toda la familia `Workspaces` que se encontró (además de "leave"):

| Endpoint | Para qué |
|---|---|
| `POST /api/v1/workspaces` | Crear un workspace nuevo. Te enrola como `owner` automáticamente |
| `DELETE /api/v1/workspaces/{id}` + `POST .../restore` | Borrar y recuperar el workspace entero |
| `PATCH /api/v1/workspaces/{id}` | Editar el workspace. Hoy solo se puede cambiar el `name`. Solo owner |
| `GET/POST .../invites`, `POST/DELETE .../invites/{inviteId}` | Gestión de invitaciones |
| `POST /api/v1/me/active-workspace` | Cambiar cuál es tu workspace activo (setea la cookie `bk_active_ws`) |

**No existe**: transferir la propiedad (ownership) de un workspace, ni cambiar el
role/status de un miembro (por ejemplo pasar a alguien de `active` a `suspended`, o ascender
a un co-owner). Coincide con lo que decía el brief.

## 7. Estado de los datos en staging (contexto, no es tu usuario)

Números del momento del reconocimiento:

- 585 workspaces, 594 filas de membresía, 79 usuarios, 6917 access_tokens.
- Membresías activas: 571 `owner`, 14 `member`, 6 `viewer`, más 2 `owner` suspendidos y 1 `admin`.
- 14 usuarios tienen 2 o más membresías activas. 65 tienen exactamente 1.

Qué implica para armar fixtures (los escenarios de prueba):

- "Un co-owner se va" y "un member simple se va" son **raros** en staging: hay apenas ~21
  filas activas que no son owner en toda la instancia. Vas a tener que **construir esos
  escenarios a mano**.
- Problema de calidad de datos: hay 15 workspaces sin borrar con **cero owners activos**,
  más 2 filas `owner/suspended`. O sea, la regla BR-8 ("siempre debe haber un owner") **no
  se cumple en los datos que ya están** en staging. Al elegir sobre qué workspace probar,
  cuidado de no agarrar uno de esos.

## 8. Qué NO está en este documento

Igual que el documento sellado: acá no hay diseño de pruebas. No dice qué asertar ni con qué
técnica. Eso es la pasada asistida (paso 5).

---

## Nota de comparación (para vos)

Este Documento 2 y `reconocimiento-hallazgos-SELLADO.md` dicen lo mismo. Si el Documento 2
se lee mejor, la diferencia está en: (a) glosario por adelantado, (b) una columna "en
criollo" en las tablas de guards y códigos, (c) frases más cortas, (d) menos densidad por
párrafo. Anotá qué partes siguen costando y las ajustamos.
