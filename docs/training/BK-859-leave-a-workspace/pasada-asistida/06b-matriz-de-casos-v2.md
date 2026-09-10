# Matriz de casos — Pasada asistida BK-859 (v2)

> Segunda versión de `06-matriz-de-casos.md`. Se deja `06` intacto para comparar.
> Cambia la **organización**, no los 28 casos: siguen siendo los mismos, con distinto orden e ID.

---

## Qué cambió respecto de la v1

| Cambio | v1 | v2 |
|---|---|---|
| Orden de los bloques | Por capa técnica (auth, guards, happy path, ...). Empezaba en `TC-01 = 401 sin sesión`, un caso que no sale de ninguna AC | **Por criterio de aceptación primero.** Bloque 1 = Escenario 1, ... Bloque 5 = Escenario C. Recién después, contrato y seguridad |
| Numeración | `TC-01` era material fuera de AC | `TC-01` es el primer caso del Escenario 1. Los `TC-18`..`TC-28` son los de fuera de AC |
| Casos por prioridad | Solo una columna `Prio` en cada tabla | **Bloque aparte al final** con las tres listas explícitas (P1 / P2 / P3) |
| Resumen de cobertura | Uno solo (por escenario de AC) | **Dos vistas**: (A) por criterio de aceptación, (B) por dimensión de calidad (técnica, capa, naturaleza, prioridad) |

Mapa de renumeración v1 → v2 al final del documento.

---

## Convenciones

- **Nombre**: `BK-859: TC-NN: should <resultado esperado> [when <condición>] [given <precondición>]`
- **Prioridad**: `P1` imprescindible (AC ratificada o guard) · `P2` importante (efecto colateral, negativo secundario, UI no crítica) · `P3` si hay tiempo (fixture difícil o falta respuesta de Dev)
- **Capa**: `API` request directa · `UI` navegador · `DB` validación en base · `AGENT` ruta de IA agéntica
- **Téc.**: técnica de diseño que dispara el caso (`EP` / `BVA` / `ST` state-transition / `DT` decision table / `EG` error-guessing / `recon` hallazgo de la corrida de reconocimiento)

---

# Parte 1 — Casos por criterio de aceptación (lo principal de esta historia)

## Bloque 1 — Escenario 1: dejar un workspace pide confirmación y reasigna el activo

| ID | Título | Téc. | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|
| TC-01 | should let a non-owner member leave the workspace | DT, EP, ST | API + DB | P1 | D | `200`. La fila de `workspace_members` del usuario queda borrada |
| TC-02 | should name the workspace in the confirmation dialog before committing | ST | UI | P1 | C o D | Al elegir "Leave workspace" aparece un diálogo que **nombra** el workspace. Mecanismo (confirmar/cancelar vs escribir-para-confirmar) = *open question*: caso agnóstico del mecanismo |
| TC-03 | should not remove the membership when the confirmation dialog is cancelled | ST | UI | P2 | D | Cancelar el diálogo: la membership sigue, nada cambia |
| TC-04 | should switch the active workspace to the oldest remaining membership and rotate the cookie when leaving the active one | ST, BVA, EP | API + UI | P1 | C o D (target = activo) | Response trae `newActiveWorkspaceId`/`Name` = la membership restante más antigua (`joined_at asc`). La cookie `bk_active_ws` cambia. El chrome global refleja el nuevo activo sin refrescar |
| TC-05 | should keep the active workspace unchanged when leaving a non-active workspace | ST, EP | API | P2 | C o D (target ≠ activo) | `newActiveWorkspaceId` = el activo previo. La cookie no cambia |

## Bloque 2 — Escenario 2: no se puede dejar un workspace que se posee en soledad

| ID | Título | Téc. | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|
| TC-06 | should reject with 409 `sole_owner` when the caller is the only owner and has 2+ memberships | DT, BVA, ST, EP | API | P1 | B | `409`. La fila sigue `active`. Nada se borra |
| TC-07 | should disable or hide "Leave workspace" with a sole-owner explanation | DT, EP | UI | P1 | B | La acción está deshabilitada u oculta + mensaje: sos el único owner, hay que transferir/compartir ownership antes. Mockup: badge "sole owner" + copy "You're its only owner. Ownership transfer isn't available yet." |
| TC-08 | should let the client tell the two 409 reasons apart via `message`/`details` | recon (H1) | API | P1 | A y B | Cada `409` trae en `message`/`details` info suficiente para distinguir `last_membership` de `sole_owner`. **Si no se puede → elevar improvement** (ver `07`) |

## Bloque 3 — Escenario A: no se puede dejar la única membresía

| ID | Título | Téc. | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|
| TC-09 | should reject with 409 `last_membership` when it is the caller's only active membership | DT, BVA, ST, EP | API | P1 | A | `409`. La fila sigue `active` |
| TC-10 | should not render "Leave workspace" (no reachable dialog) when it is the user's only workspace | DT, EP | UI | P1 | A | La acción **no se renderiza**. No hay diálogo de confirmación alcanzable. Mismo trato que el Escenario 2 |
| TC-11 | should return `last_membership` (not `sole_owner`) when both conditions hold | BVA | API | P1 | A | `409` con motivo `last_membership`. Verifica el **orden de precedencia** de los guards (guard 3 antes que guard 4) |

## Bloque 4 — Escenario B: sin efecto cascada sobre el contenido, PAT incluido

| ID | Título | Téc. | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|
| TC-12 | should leave authored ATCs and user stories intact and inaccessible to the ex-member | EP | DB + API | P1 | D + contenido autorado | El contenido sigue en el workspace sin cambios. El ex-miembro que hace `GET` de esos recursos → `403`/`404` |
| TC-13 | should auto-revoke the caller's PAT scoped to the left workspace, in the same transaction | ST, EP | API + DB | P1 | D + PAT con scope del target | Tras el `200`: `access_tokens.revoked_at` = timestamp del leave. Usar ese PAT → `401` |
| TC-14 | should NOT revoke the caller's PAT scoped to a different workspace | ST, EP | API + DB | P2 | D + 2 PAT | El PAT del otro workspace sigue devolviendo `200` en sus llamadas |
| TC-15 | should hard-delete the membership row (not set it to `suspended`) | recon (H2), ST | DB | P1 | C o D | Tras el `200`, la fila **no existe** en `workspace_members`. No aparece como `suspended` |

## Bloque 5 — Escenario C: un co-owner puede irse si quedan otros owners

| ID | Título | Téc. | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|
| TC-16 | should let a co-owner leave when another active owner remains | DT, BVA, ST, EP | API + DB | P1 | C | `200`. La fila del que se fue: borrada. El workspace conserva al otro owner con privilegios intactos |
| TC-17 | should let an `admin` leave without triggering `sole_owner` | recon (H5), EP | API | P2 | D (variante `admin`) | `200`. El guard mira `role='owner'`, no `admin`. Refuerza que el gate del Escenario C es por conteo de owners |

---

# Parte 2 — Casos fuera de los criterios de aceptación (contrato y seguridad)

> Doctrina: **verificar las ACs es el piso, no el techo.** Estos casos salen de los hallazgos de la recon y de las técnicas, no de una AC. Son el aporte de la pasada asistida.

## Bloque 6 — Contrato del endpoint y autenticación

| ID | Título | Téc. | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|
| TC-18 | should reject with 401 when no session is present | DT, EP | API | P1 | — | `401`, cuerpo `ErrorEnvelope` |
| TC-19 | should reject with 403 when authenticated via PAT | DT, EP | API | P1 | B + PAT | `403`. El endpoint es cookie-only. La membership no se toca |
| TC-20 | should return 404 when the workspace id does not exist | DT, EP | API | P2 | sesión cookie | `404`. UUID válido en forma, inexistente |
| TC-21 | should return 404 when the caller is not a member of the workspace | DT, EP | API | P1 | cookie + WS ajeno | `404` `not_a_member` |
| TC-22 | should return 404 when the caller's membership is `invited` | EP, ST | API | P2 | usuario con invitación sin aceptar | `404`. No hay fila `active` |
| TC-23 | should return 404 when the caller's membership is `suspended` | EP, ST | API | P2 | usuario con membership suspendida | `404`. La fila existe pero no está `active` |
| TC-24 | should return 404 on a second leave attempt for the same workspace | ST, EG | API | P2 | D | Primer intento `200`; segundo `404`. No `500`, no estado inconsistente |
| TC-25 | should resolve the new active workspace deterministically when two remaining memberships share `joined_at` | BVA | API | P3 | 3 memberships, 2 con `joined_at` idéntico | Comportamiento no especificado. Verificar que al menos es determinístico. Si no se puede montar el empate → pregunta para Dev |

## Bloque 7 — Seguridad y robustez (Error-Guessing)

| ID | Título | Téc. | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|
| TC-26 | should enforce the same guards when the leave is requested through the agentic AI route | EG | AGENT + API | P2 | A o B | La IA agéntica llega al mismo RPC `SECURITY DEFINER`. Con sole owner / única membresía debe fallar con `409`, no ejecutar el `DELETE`. No hay ruta de bypass |
| TC-27 | should never leave a workspace with zero active owners when two co-owners leave concurrently | EG | API | P3 | C (2 owners) | En un race de dos co-owners saliendo casi a la vez, uno recibe `409` `sole_owner`. El workspace nunca queda con 0 owners activos (BR-8) |
| TC-28 | should reject a malformed workspace id cleanly | EG | API | P2 | cookie | UUID con otra capitalización / espacios / formato inválido → `400` o `404` limpio, nunca `500` |

---

# Parte 3 — Casos por prioridad (resumen aparte)

## P1 — imprescindibles (16)

Cobertura mínima. Cada uno cubre una AC ratificada o un guard.

`TC-01` `TC-02` `TC-04` `TC-06` `TC-07` `TC-08` `TC-09` `TC-10` `TC-11` `TC-12` `TC-13` `TC-15` `TC-16` `TC-18` `TC-19` `TC-21`

## P2 — importantes (10)

Efecto colateral, negativo secundario, o capa UI no crítica. Se corren si el tiempo alcanza tras los P1.

`TC-03` `TC-05` `TC-14` `TC-17` `TC-20` `TC-22` `TC-23` `TC-24` `TC-26` `TC-28`

## P3 — si hay tiempo (2)

Requieren un fixture difícil de montar o una respuesta de Dev que todavía no está.

`TC-25` (empate de `joined_at`) · `TC-27` (race de co-owners)

---

# Parte 4 — Cobertura

## Vista A — por criterio de aceptación

Qué casos tocan cada escenario. Un caso puede aparecer en más de una fila.

| Escenario AC | Casos | ¿Cubierto? |
|---|---|---|
| **S1** — confirmación + fallback de activo | TC-01, TC-02, TC-03, TC-04, TC-05 | Sí. Falta cerrar el mecanismo del diálogo (*open question*) |
| **S2** — bloqueo de sole owner | TC-06, TC-07, TC-08, TC-11 | Sí |
| **A** — bloqueo de única membresía | TC-09, TC-10, TC-11 | Sí |
| **B** — sin cascada + revoca PAT | TC-12, TC-13, TC-14, TC-15 | Sí |
| **C** — co-owner puede irse | TC-16, TC-17 | Sí, pendiente de montar el fixture C |
| Fuera de las ACs (contrato + seguridad) | TC-18 a TC-28 | — |

## Vista B — por dimensión de calidad

Responde "¿qué tan repartida está la cobertura?", no "¿cubrí las ACs?". Los conteos con capa/técnica múltiple suman más de 28 porque un caso puede contar en varias celdas.

| Dimensión | Reparto |
|---|---|
| **Técnica disparadora (principal)** | Decision Table: 10 · State-Transition: 6 · Error-Guessing: 4 · Equivalence Partitioning: 3 · Boundary Value: 2 · Hallazgo de recon: 3. *(EP y BVA además actúan como técnica secundaria en la mayoría de los casos)* |
| **Capa** | API: 23 · UI: 5 · DB: 6 · AGENT: 1 |
| **Naturaleza del caso** | Camino feliz: 4 (TC-01, 02, 16, 17) · Bloqueo esperado (guard/permiso): 5 (TC-06, 07, 09, 10, 11) · Error de contrato 4xx: 7 (TC-08, 18, 19, 20, 21, 22, 23) · Efecto colateral del `200`: 7 (TC-04, 05, 12, 13, 14, 15, 25) · Robustez / abuso: 5 (TC-03, 24, 26, 27, 28) |
| **Prioridad** | P1: 16 · P2: 10 · P3: 2 |

**Lectura rápida de la Vista B:**

- Ninguna técnica quedó sin usar. Decision Table domina porque el corazón de la feature es una cadena de guards.
- El peso está en `API` (23 de 28). Es correcto: la recon confirmó que el núcleo es API, no UI. `UI` cubre solo lo que las ACs piden ver (confirmación, estados bloqueados).
- Hay equilibrio entre camino feliz (4), bloqueos (5) y errores de contrato (7). No es una matriz "solo happy path".
- 7 casos verifican **efectos colaterales del `200`** (nuevo activo, cookie, revoca PAT, hard delete). Ese es el riesgo real de esta feature: que el leave "funcione" pero deje algo mal atrás.

---

# Parte 5 — Fixtures

| Fixture | Qué es | Estado |
|---|---|---|
| **A** | `Bunkai 3` — sole owner + única membresía (los dos bloqueos juntos) | Ya existe |
| **B** | `Fixture B BK-859` — 2do workspace propio. Levanta `last_membership`, aísla `sole_owner` | Creado (`7a14b2d9-24fa-481b-821d-50da6ca01491`, 2026-09-10) |
| **C** | B + un 2do `owner` en ese workspace | **Falta.** Difícil: no se invita como `owner`, no hay endpoint para promover. Probablemente `INSERT` por DB. Verificar permisos de `qa_inspector_rw` |
| **D** | Otro usuario invita al nuestro como `member` (variante `admin` para TC-17) | **Falta.** Necesita un 2do usuario con su propio workspace |

---

# Parte 6 — Mapa de renumeración v1 → v2

| v2 | v1 | Caso |
|---|---|---|
| TC-01 | TC-12 | member no-owner deja el workspace |
| TC-02 | TC-22 | diálogo de confirmación nombra el workspace |
| TC-03 | TC-23 | cancelar el diálogo no borra nada |
| TC-04 | TC-16 | dejar el activo: nuevo activo + cookie rotada |
| TC-05 | TC-17 | dejar un no-activo: activo sin cambio |
| TC-06 | TC-08 | `409 sole_owner` (API) |
| TC-07 | TC-24 | UI: "Leave" deshabilitada + mensaje sole owner |
| TC-08 | TC-10 | distinguir los dos `409` por `message`/`details` |
| TC-09 | TC-07 | `409 last_membership` (API) |
| TC-10 | TC-25 | UI: la acción no se renderiza |
| TC-11 | TC-09 | precedencia: `last_membership` antes que `sole_owner` |
| TC-12 | TC-21 | contenido autorado queda intacto |
| TC-13 | TC-19 | PAT del target revocado |
| TC-14 | TC-20 | PAT de otro workspace intacto |
| TC-15 | TC-14 | hard delete de la fila |
| TC-16 | TC-11 | co-owner se va, otro owner conserva privilegios |
| TC-17 | TC-13 | admin se va sin disparar `sole_owner` |
| TC-18 | TC-01 | `401` sin sesión |
| TC-19 | TC-02 | `403` con PAT |
| TC-20 | TC-03 | `404` workspace inexistente |
| TC-21 | TC-04 | `404` no es miembro |
| TC-22 | TC-05 | `404` membership `invited` |
| TC-23 | TC-06 | `404` membership `suspended` |
| TC-24 | TC-15 | segundo intento de leave → `404` |
| TC-25 | TC-18 | empate de `joined_at` |
| TC-26 | TC-26 | ruta agéntica sin bypass |
| TC-27 | TC-27 | race de co-owners |
| TC-28 | TC-28 | UUID malformado |
