# Matriz de casos — Pasada asistida BK-859

> Diseño de pruebas para "Leave a workspace". Sale de los criterios de aceptación, del reconocimiento técnico sellado (`../reconocimiento-hallazgos-SELLADO.md`) y de las técnicas formales de diseño.
> Documento local de práctica. No se sube a Jira.

---

## Cómo leer esta matriz

La matriz se puede recorrer por **dos ejes**, y los dos están soportados con el mismo nivel de detalle:

| Eje | Dónde | Cuándo usarlo |
|---|---|---|
| **Por criterio de aceptación** | Parte 1 (Bloques 1-5) | Querés cubrir lo que la historia promete, escenario por escenario. Es el eje principal |
| **Por dimensión de calidad** | Parte 4, Vista B | Querés priorizar por técnica, por capa, o por **naturaleza del caso** (camino feliz, bloqueo, contrato, efecto colateral, robustez). Útil cuando el tiempo es acotado y hay que elegir qué familia de riesgo atacar primero |

Complementan: **Parte 2** son los casos que no nacen de una AC (contrato de API + seguridad). **Parte 3** es el índice por prioridad. **Parte 5** son los fixtures.

---

## Convenciones

**Nombre del caso:** `BK-859: TC-NN: debería <resultado esperado> [cuando <condición>] [dado <precondición>]`. Negativos: `no debería ...`. Identificadores, enums, códigos de error y etiquetas literales de UI van textuales (`sole_owner`, `last_membership`, `409`, `PAT`, `joined_at`, `suspended`, `invited`, `Leave workspace`).

**Prioridad:** `P1` imprescindible (AC ratificada o guard) · `P2` importante (efecto colateral, negativo secundario, UI no crítica) · `P3` si hay tiempo (fixture difícil o falta respuesta de Dev).

**Capa:** `API` request directa al endpoint · `UI` navegador · `DB` validación en base · `AGENT` ruta de IA agéntica.

**Téc.:** técnica que dispara el caso — `EP` equivalence partitioning · `BVA` boundary value analysis · `ST` state-transition · `DT` decision table · `EG` error-guessing · `recon` hallazgo de la corrida de reconocimiento.

**Naturaleza:** familia de riesgo del caso. Se explica en detalle en la Parte 4, Vista B.3. Resumen:

| Valor | En una línea |
|---|---|
| `Feliz` | La operación se completa y el estado queda como se espera |
| `Bloqueo` | Un guard o un permiso impide la operación y devuelve el error correcto |
| `Contrato` | Entrada inválida o no autorizada devuelve el status HTTP correcto del contrato |
| `Colateral` | Además del resultado principal se dispara un cambio secundario (cookie, PAT, hard delete, nuevo activo) |
| `Robustez` | Entradas raras, repetición, concurrencia o rutas alternativas |

---

# Parte 1 — Casos por criterio de aceptación

## Bloque 1 — Escenario 1: dejar un workspace pide confirmación y reasigna el activo

| ID | Título | Prio | Capa | Naturaleza | Téc. | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-01 | debería permitir que un miembro sin rol de owner deje el workspace | P1 | API + DB | Feliz | DT, EP, ST | D | `200`. La fila de `workspace_members` del usuario queda borrada |
| TC-02 | debería nombrar el workspace en el diálogo de confirmación antes de confirmar | P1 | UI | Feliz | ST | C o D | Al elegir `Leave workspace` aparece un diálogo que **nombra** el workspace. Mecanismo (confirmar/cancelar vs escribir-para-confirmar) = *open question*: caso agnóstico del mecanismo |
| TC-03 | no debería eliminar la membresía cuando se cancela el diálogo de confirmación | P2 | UI | Robustez | ST | D | Cancelar el diálogo: la membresía sigue, nada cambia |
| TC-04 | debería cambiar el workspace activo a la membresía restante más antigua y rotar la cookie cuando se deja el que estaba activo | P1 | API + UI | Colateral | ST, BVA, EP | C o D (target = activo) | Response trae `newActiveWorkspaceId`/`Name` = la membresía restante más antigua (`joined_at asc`). La cookie `bk_active_ws` cambia. El chrome global refleja el nuevo activo sin refrescar |
| TC-05 | debería mantener el workspace activo sin cambios cuando se deja un workspace que no es el activo | P2 | API | Colateral | ST, EP | C o D (target ≠ activo) | `newActiveWorkspaceId` = el activo previo. La cookie no cambia |

## Bloque 2 — Escenario 2: no se puede dejar un workspace que se posee en soledad

| ID | Título | Prio | Capa | Naturaleza | Téc. | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-06 | debería rechazar con `409` `sole_owner` cuando quien llama es el único owner y tiene 2 o más membresías | P1 | API | Bloqueo | DT, BVA, ST, EP | B | `409`. La fila sigue `active`. Nada se borra |
| TC-07 | debería deshabilitar u ocultar `Leave workspace` con un mensaje de único owner | P1 | UI | Bloqueo | DT, EP | B | Acción deshabilitada u oculta + mensaje: sos el único owner, hay que transferir/compartir ownership antes. Mockup: badge "sole owner" + copy "You're its only owner. Ownership transfer isn't available yet." |
| TC-08 | debería permitir al cliente distinguir los dos motivos de `409` mediante `message`/`details` | P1 | API | Contrato | recon (H1) | A y B | Cada `409` trae en `message`/`details` info suficiente para distinguir `last_membership` de `sole_owner`. **Si no se puede → elevar improvement** (ver `07`) |

## Bloque 3 — Escenario A: no se puede dejar la única membresía

| ID | Título | Prio | Capa | Naturaleza | Téc. | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-09 | debería rechazar con `409` `last_membership` cuando es la única membresía activa de quien llama | P1 | API | Bloqueo | DT, BVA, ST, EP | A | `409`. La fila sigue `active` |
| TC-10 | no debería renderizar `Leave workspace` (sin diálogo alcanzable) cuando es el único workspace del usuario | P1 | UI | Bloqueo | DT, EP | A | La acción **no se renderiza**. No hay diálogo de confirmación alcanzable. Mismo trato que el Escenario 2 |
| TC-11 | debería devolver `last_membership` (no `sole_owner`) cuando se cumplen ambas condiciones | P1 | API | Bloqueo | BVA | A | `409` con motivo `last_membership`. Verifica el **orden de precedencia** de los guards (guard 3 antes que guard 4) |

## Bloque 4 — Escenario B: sin efecto cascada sobre el contenido, PAT incluido

| ID | Título | Prio | Capa | Naturaleza | Téc. | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-12 | debería dejar los ATCs e historias de usuario autorados intactos e inaccesibles para el ex miembro | P1 | DB + API | Colateral | EP | D + contenido autorado | El contenido sigue en el workspace sin cambios. El ex miembro que hace `GET` de esos recursos → `403`/`404` |
| TC-13 | debería auto-revocar el `PAT` de quien llama con alcance del workspace que deja, en la misma transacción | P1 | API + DB | Colateral | ST, EP | D + PAT con scope del target | Tras el `200`: `access_tokens.revoked_at` = timestamp del leave. Usar ese PAT → `401` |
| TC-14 | no debería revocar el `PAT` de quien llama con alcance de otro workspace | P2 | API + DB | Colateral | ST, EP | D + 2 PAT | El PAT del otro workspace sigue devolviendo `200` en sus llamadas |
| TC-15 | debería eliminar por completo la fila de membresía (no dejarla en `suspended`) | P1 | DB | Colateral | recon (H2), ST | C o D | Tras el `200`, la fila **no existe** en `workspace_members`. No aparece como `suspended` |

## Bloque 5 — Escenario C: un co-owner puede irse si quedan otros owners

| ID | Título | Prio | Capa | Naturaleza | Téc. | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-16 | debería permitir que un co-owner deje el workspace cuando queda otro owner activo | P1 | API + DB | Feliz | DT, BVA, ST, EP | C | `200`. La fila del que se fue: borrada. El workspace conserva al otro owner con privilegios intactos |
| TC-17 | debería permitir que un `admin` deje el workspace sin disparar `sole_owner` | P2 | API | Feliz | recon (H5), EP | D (variante `admin`) | `200`. El guard mira `role='owner'`, no `admin`. Refuerza que el gate del Escenario C es por conteo de owners |

---

# Parte 2 — Casos fuera de los criterios de aceptación (contrato y seguridad)

> **Verificar las ACs es el piso, no el techo.** Estos casos salen de los hallazgos de la recon y de las técnicas, no de una AC.

## Bloque 6 — Contrato del endpoint y autenticación

| ID | Título | Prio | Capa | Naturaleza | Téc. | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-18 | debería rechazar con `401` cuando no hay sesión | P1 | API | Contrato | DT, EP | — | `401`, cuerpo `ErrorEnvelope` |
| TC-19 | debería rechazar con `403` cuando se autentica mediante `PAT` | P1 | API | Contrato | DT, EP | B + PAT | `403`. El endpoint es cookie-only. La membresía no se toca |
| TC-20 | debería devolver `404` cuando el id de workspace no existe | P2 | API | Contrato | DT, EP | sesión cookie | `404`. UUID válido en forma, inexistente |
| TC-21 | debería devolver `404` cuando quien llama no es miembro del workspace | P1 | API | Contrato | DT, EP | cookie + WS ajeno | `404` `not_a_member` |
| TC-22 | debería devolver `404` cuando la membresía de quien llama está en `invited` | P2 | API | Contrato | EP, ST | usuario con invitación sin aceptar | `404`. No hay fila `active` |
| TC-23 | debería devolver `404` cuando la membresía de quien llama está en `suspended` | P2 | API | Contrato | EP, ST | usuario con membresía suspendida | `404`. La fila existe pero no está `active` |
| TC-24 | debería devolver `404` ante un segundo intento de leave sobre el mismo workspace | P2 | API | Robustez | ST, EG | D | Primer intento `200`; segundo `404`. No `500`, no estado inconsistente |
| TC-25 | debería resolver el nuevo workspace activo de forma determinística cuando dos membresías restantes comparten `joined_at` | P3 | API | Colateral | BVA | 3 membresías, 2 con `joined_at` idéntico | Comportamiento no especificado. Verificar que al menos es determinístico. Si no se puede montar el empate → pregunta para Dev |

## Bloque 7 — Seguridad y robustez (Error-Guessing)

| ID | Título | Prio | Capa | Naturaleza | Téc. | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-26 | debería aplicar los mismos guards cuando el leave se solicita por la ruta de IA agéntica | P2 | AGENT + API | Robustez | EG | A o B | La IA agéntica llega al mismo RPC `SECURITY DEFINER`. Con sole owner / única membresía debe fallar con `409`, no ejecutar el `DELETE`. No hay ruta de bypass |
| TC-27 | no debería dejar nunca un workspace con cero owners activos cuando dos co-owners salen de forma concurrente | P3 | API | Robustez | EG | C (2 owners) | En un race de dos co-owners saliendo casi a la vez, uno recibe `409` `sole_owner`. El workspace nunca queda con 0 owners activos (BR-8) |
| TC-28 | debería rechazar un id de workspace mal formado de forma limpia | P2 | API | Robustez | EG | cookie | UUID con otra capitalización / espacios / formato inválido → `400` o `404` limpio, nunca `500` |

---

# Parte 3 — Índice por prioridad

## P1 — imprescindibles (16)

Cobertura mínima. Cada uno cubre una AC ratificada o un guard.

| ID | Título breve | Escenario | Capa | Naturaleza |
|---|---|---|---|---|
| TC-01 | miembro no-owner deja el workspace | S1 | API + DB | Feliz |
| TC-02 | el diálogo de confirmación nombra el workspace | S1 | UI | Feliz |
| TC-04 | dejar el activo reasigna el activo y rota la cookie | S1 | API + UI | Colateral |
| TC-06 | `409 sole_owner` por API | S2 | API | Bloqueo |
| TC-07 | UI oculta/deshabilita `Leave workspace` + mensaje sole owner | S2 | UI | Bloqueo |
| TC-08 | los dos `409` se distinguen por `message`/`details` | S2 | API | Contrato |
| TC-09 | `409 last_membership` por API | A | API | Bloqueo |
| TC-10 | UI no renderiza `Leave workspace` en el único workspace | A | UI | Bloqueo |
| TC-11 | precedencia: `last_membership` antes que `sole_owner` | A / S2 | API | Bloqueo |
| TC-12 | contenido autorado queda intacto, ex miembro sin acceso | B | DB + API | Colateral |
| TC-13 | el PAT del workspace dejado se auto-revoca | B | API + DB | Colateral |
| TC-15 | hard delete de la fila de membresía | B | DB | Colateral |
| TC-16 | co-owner deja, el otro owner conserva privilegios | C | API + DB | Feliz |
| TC-18 | `401` sin sesión | contrato | API | Contrato |
| TC-19 | `403` con `PAT` (cookie-only) | contrato | API | Contrato |
| TC-21 | `404` cuando no es miembro | contrato | API | Contrato |

## P2 — importantes (10)

Se corren si el tiempo alcanza tras los P1.

| ID | Título breve | Escenario | Capa | Naturaleza |
|---|---|---|---|---|
| TC-03 | cancelar el diálogo no borra nada | S1 | UI | Robustez |
| TC-05 | dejar un no-activo no cambia el activo | S1 | API | Colateral |
| TC-14 | el PAT de otro workspace no se revoca | B | API + DB | Colateral |
| TC-17 | `admin` deja sin disparar `sole_owner` | C | API | Feliz |
| TC-20 | `404` cuando el workspace no existe | contrato | API | Contrato |
| TC-22 | `404` cuando la membresía está en `invited` | contrato | API | Contrato |
| TC-23 | `404` cuando la membresía está en `suspended` | contrato | API | Contrato |
| TC-24 | `404` en el segundo intento de leave | contrato | API | Robustez |
| TC-26 | la ruta de IA agéntica respeta los guards | seguridad | AGENT + API | Robustez |
| TC-28 | id de workspace mal formado se rechaza limpio | seguridad | API | Robustez |

## P3 — si hay tiempo (2)

Requieren un fixture difícil de montar o una respuesta de Dev que todavía no está.

| ID | Título breve | Escenario | Capa | Naturaleza |
|---|---|---|---|---|
| TC-25 | nuevo activo determinístico ante empate de `joined_at` | contrato | API | Colateral |
| TC-27 | nunca 0 owners ante un race de co-owners | seguridad | API | Robustez |

---

# Parte 4 — Cobertura

## Vista A — por criterio de aceptación

| Escenario AC | Casos | ¿Cubierto? |
|---|---|---|
| **S1** — confirmación + fallback de activo | TC-01, TC-02, TC-03, TC-04, TC-05 | Sí. Falta cerrar el mecanismo del diálogo (*open question*) |
| **S2** — bloqueo de sole owner | TC-06, TC-07, TC-08, TC-11 | Sí |
| **A** — bloqueo de única membresía | TC-09, TC-10, TC-11 | Sí |
| **B** — sin cascada + revoca PAT | TC-12, TC-13, TC-14, TC-15 | Sí |
| **C** — co-owner puede irse | TC-16, TC-17 | Sí, pendiente de montar el fixture C |
| Fuera de las ACs (contrato + seguridad) | TC-18 a TC-28 | — |

## Vista B — por dimensión de calidad

Responde "¿qué tan repartida está la cobertura?". Cada sub-vista es un índice completo: se puede empezar a testear desde cualquiera de ellas.

### B.1 — por técnica disparadora (principal)

| Técnica | Casos | Conteo |
|---|---|---|
| Decision Table (`DT`) | TC-01, TC-06, TC-07, TC-09, TC-10, TC-16, TC-18, TC-19, TC-20, TC-21 | 10 |
| State-Transition (`ST`) | TC-02, TC-03, TC-04, TC-05, TC-13, TC-14 | 6 |
| Error-Guessing (`EG`) | TC-24, TC-26, TC-27, TC-28 | 4 |
| Equivalence Partitioning (`EP`) | TC-12, TC-22, TC-23 | 3 |
| Boundary Value (`BVA`) | TC-11, TC-25 | 2 |
| Hallazgo de recon | TC-08, TC-15, TC-17 | 3 |

`EP` y `BVA` además actúan como técnica secundaria en la mayoría de los casos; la columna cuenta solo la técnica que **origina** el caso.

### B.2 — por capa

Un caso puede tocar más de una capa, así que la suma supera 28.

| Capa | Casos | Conteo |
|---|---|---|
| `API` | todos menos TC-02, TC-03, TC-07, TC-10, TC-15 | 23 |
| `UI` | TC-02, TC-03, TC-04, TC-07, TC-10 | 5 |
| `DB` | TC-01, TC-12, TC-13, TC-14, TC-15, TC-16 | 6 |
| `AGENT` | TC-26 | 1 |

### B.3 — por naturaleza del caso

Este es el índice para elegir **qué familia de riesgo atacar primero** cuando no alcanza para todo.

| Naturaleza | Qué verifica | Cuándo recorrer la matriz por acá | Casos | Conteo |
|---|---|---|---|---|
| **Feliz** | La operación se completa y el estado final es el esperado | Querés confirmar que "leave" funciona en las formas de membership permitidas (member, co-owner, admin) antes de mirar los bordes | TC-01, TC-02, TC-16, TC-17 | 4 |
| **Bloqueo** | Un guard de negocio o un permiso frena la operación y devuelve el error correcto | Querés confirmar que los candados (`sole_owner`, `last_membership`, UI oculta) frenan exactamente lo que deben, ni de más ni de menos | TC-06, TC-07, TC-09, TC-10, TC-11 | 5 |
| **Contrato** | Entrada inválida o no autorizada devuelve el status HTTP del contrato de la API | Querés validar el contrato del endpoint (`401` / `403` / `404`) de forma aislada, sin depender de reglas de negocio ni de la UI | TC-08, TC-18, TC-19, TC-20, TC-21, TC-22, TC-23 | 7 |
| **Colateral** | Además del resultado principal, se dispara un cambio secundario: nuevo activo, cookie `bk_active_ws`, revocación de `PAT`, hard delete | Querés cazar el riesgo central de esta feature: que el leave "ande" pero deje algo mal atrás | TC-04, TC-05, TC-12, TC-13, TC-14, TC-15, TC-25 | 7 |
| **Robustez** | Entradas raras, repetición, concurrencia y rutas alternativas (IA agéntica, doble submit, race, UUID mal formado) | Querés estresar los bordes y las rutas no felices que la experiencia dice mirar aunque ninguna AC las pida | TC-03, TC-24, TC-26, TC-27, TC-28 | 5 |

### B.4 — por prioridad

| Prioridad | Qué significa | Casos | Conteo |
|---|---|---|---|
| `P1` | Imprescindible. AC ratificada o guard | TC-01, TC-02, TC-04, TC-06, TC-07, TC-08, TC-09, TC-10, TC-11, TC-12, TC-13, TC-15, TC-16, TC-18, TC-19, TC-21 | 16 |
| `P2` | Importante. Efecto colateral, negativo secundario, UI no crítica | TC-03, TC-05, TC-14, TC-17, TC-20, TC-22, TC-23, TC-24, TC-26, TC-28 | 10 |
| `P3` | Si hay tiempo. Fixture difícil o falta respuesta de Dev | TC-25, TC-27 | 2 |

### Lectura rápida

- Ninguna técnica quedó sin usar. Decision Table domina porque el corazón de la feature es una cadena de guards.
- El peso está en `API` (23 de 28). La recon confirmó que el núcleo es API, no UI. `UI` cubre solo lo que las ACs piden ver.
- La naturaleza está equilibrada: 4 feliz, 5 bloqueo, 7 contrato, 7 colateral, 5 robustez. No es una matriz "solo happy path".
- **Colateral (7 casos)** es el grupo a no saltear: nuevo activo, cookie, revoca PAT, hard delete. Ahí vive el riesgo de que el leave deje residuos.

---

# Parte 5 — Fixtures

| Fixture | Qué es | Estado |
|---|---|---|
| **A** | `Bunkai 3` — sole owner + única membresía (los dos bloqueos juntos) | Ya existe |
| **B** | `Fixture B BK-859` — 2do workspace propio. Levanta `last_membership`, aísla `sole_owner` | Creado (`7a14b2d9-24fa-481b-821d-50da6ca01491`, 2026-09-10) |
| **C** | B + un 2do `owner` en ese workspace | **Falta.** Difícil: no se invita como `owner`, no hay endpoint para promover. Probablemente `INSERT` por DB. Verificar permisos de `qa_inspector_rw` |
| **D** | Otro usuario invita al nuestro como `member` (variante `admin` para TC-17) | **Falta.** Necesita un 2do usuario con su propio workspace |
