# Matriz de casos — Pasada asistida BK-859

> El entregable central. Consolida los casos que salieron de los checkpoints 1–4 en una sola lista, con trazabilidad a la técnica que los generó, al escenario de AC y al fixture necesario.
> Equivale a la lista de casos de un ATP, pero acá vive como doc local (no como item de Jira).

---

## Convención de nombre

`BK-859: TC-NN: should <resultado esperado> [when <condición>] [given <precondición>]`

## Prioridad

| Nivel | Qué significa |
|---|---|
| **P1** | Imprescindible. Cubre una AC ratificada o un guard. Sin esto no hay cobertura mínima |
| **P2** | Importante. Efecto colateral, partición inválida secundaria, o capa UI no crítica |
| **P3** | Si hay tiempo. Requiere fixture difícil de montar o una respuesta de Dev que todavía no está |

## Capas

`API` = request directa al endpoint · `DB` = validación en base de datos (DBHub) · `UI` = navegador · `AGENT` = ruta de IA agéntica

---

## Bloque 1 — Autenticación y contrato del endpoint

| ID | Título | Téc. | AC | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-01 | should reject with 401 when no session is present | EP, DT-R1 | seg. | API | P1 | — | `401`, cuerpo `ErrorEnvelope` con `code` de no-autenticado |
| TC-02 | should reject with 403 when authenticated via PAT | EP, DT-R2 | contrato | API | P1 | B + PAT | `403`. El endpoint es cookie-only. La membership **no** se toca |
| TC-03 | should return 404 when the workspace id does not exist | EP, DT-R3 | — | API | P2 | sesión cookie | `404`. UUID válido en forma pero inexistente |
| TC-04 | should return 404 when the caller is not a member of the workspace | EP, DT-R3 | — | API | P1 | cookie + WS ajeno | `404` `not_a_member` |
| TC-05 | should return 404 when the caller's membership is `invited` | EP, ST-6 | — | API | P2 | usuario con invitación sin aceptar | `404`. No hay fila `active` |
| TC-06 | should return 404 when the caller's membership is `suspended` | EP, ST-7 | — | API | P2 | usuario con membership suspendida | `404`. La fila existe pero no está `active` |

---

## Bloque 2 — Guards (`last_membership`, `sole_owner`)

| ID | Título | Téc. | AC | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-07 | should reject with 409 `last_membership` when it is the caller's only active membership | EP, BVA-1, DT-R4, ST-4 | A | API | P1 | **A** | `409`. La fila sigue `active`. Nada se borra |
| TC-08 | should reject with 409 `sole_owner` when the caller is the only owner and has 2+ memberships | EP, BVA-3/6, DT-R5, ST-3 | S2 | API | P1 | **B** | `409`. La fila sigue `active` |
| TC-09 | should return `last_membership` (not `sole_owner`) when both conditions hold | BVA-5 | S2 + A | API | P1 | **A** | `409` con motivo `last_membership`. Verifica el **orden de precedencia** de los guards |
| TC-10 | should let the client tell the two 409 reasons apart via `message`/`details` | H1 | S2 | API | P1 | A y B | Cada `409` trae en `message`/`details` info suficiente para distinguir `last_membership` de `sole_owner`. **Si no se puede → elevar improvement** (ver `07`) |

---

## Bloque 3 — Camino feliz de "leave"

| ID | Título | Téc. | AC | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-11 | should let a co-owner leave when another active owner remains | EP, BVA-4, DT-R6, ST-1 | C | API + DB | P1 | **C** | `200`. La fila del que se fue: borrada. El workspace conserva al otro owner con privilegios intactos |
| TC-12 | should let a non-owner member leave | EP, DT-R7, ST-2 | S1 | API + DB | P1 | **D** | `200`. Fila borrada |
| TC-13 | should let an `admin` leave without triggering `sole_owner` | EP, H5 | — | API | P2 | D (variante `admin`) | `200`. El guard mira `role='owner'`, no `admin` |
| TC-14 | should hard-delete the membership row (not set it to `suspended`) | H2, ST-1 | B | DB | P1 | C o D | Tras el `200`, la fila **no existe** en `workspace_members`. No aparece como `suspended` |
| TC-15 | should return 404 on a second leave attempt for the same workspace | ST-5, EG-2 | — | API | P2 | D | Primer intento `200`; segundo intento `404`. No `500`, no estado inconsistente |

---

## Bloque 4 — Re-resolución del workspace activo

| ID | Título | Téc. | AC | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-16 | should switch active workspace to the oldest remaining membership and rotate the cookie when leaving the active one | EP, BVA-7, ST-8 | S1 | API + UI | P1 | C o D (target = activo) | Response trae `newActiveWorkspaceId`/`Name` = el más viejo restante (`joined_at asc`). La cookie `bk_active_ws` cambia. El switcher global refleja el nuevo activo |
| TC-17 | should keep the active workspace unchanged when leaving a non-active workspace | EP, ST-9 | — | API | P2 | C o D (target ≠ activo) | `newActiveWorkspaceId` = el activo previo. La cookie no cambia |
| TC-18 | should resolve the new active workspace deterministically when two remaining memberships share `joined_at` | BVA-8 | — | API | P3 | 3 memberships, 2 con `joined_at` idéntico | Comportamiento no especificado en el contrato. Verificar al menos que es **determinístico**. Si no se puede montar el empate → pregunta para Dev |

---

## Bloque 5 — Revocación de PAT

| ID | Título | Téc. | AC | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-19 | should auto-revoke the caller's PAT scoped to the left workspace, in the same transaction | EP, ST-11 | B | API + DB | P1 | D + PAT con scope del target | Tras el `200`: `access_tokens.revoked_at` = timestamp del leave. Usar ese PAT → `401` |
| TC-20 | should NOT revoke the caller's PAT scoped to a different workspace | EP, ST-12, H4 | B | API + DB | P2 | D + 2 PAT (uno del target, uno de otro WS) | El PAT del otro workspace sigue devolviendo `200` en sus llamadas |

---

## Bloque 6 — Contenido del workspace (sin cascada)

| ID | Título | Téc. | AC | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-21 | should leave authored ATCs and user stories intact and inaccessible to the ex-member | EP-16 | B | DB + API | P1 | D + ATCs/US autorados por el usuario en el target | El contenido sigue en el workspace sin cambios. El ex-miembro que hace `GET` de esos recursos → `403`/`404` |

---

## Bloque 7 — Estados bloqueados en la UI (S2, Scenario A)

| ID | Título | Téc. | AC | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-22 | should name the workspace in the confirmation dialog before committing | State-Transition (flujo) | S1 | UI | P1 | C o D | Al elegir "Leave workspace" aparece un diálogo que **nombra** el workspace. (Mecanismo confirmar/cancelar vs escribir-para-confirmar = *open question*, caso agnóstico del mecanismo) |
| TC-23 | should not remove the membership when the confirmation dialog is cancelled | State-Transition | S1 | UI | P2 | D | Cancelar el diálogo: la membership sigue, nada cambia |
| TC-24 | should disable or hide "Leave workspace" with a sole-owner explanation when the caller solely owns the workspace | EP, DT-R5 | S2 | UI | P1 | B | La acción está deshabilitada u oculta + mensaje: sos el único owner, hay que transferir/compartir ownership antes. (Mockup: badge "sole owner" + copy "You're its only owner. Ownership transfer isn't available yet.") |
| TC-25 | should not render "Leave workspace" (no reachable dialog) when it is the user's only workspace | EP, DT-R4 | A | UI | P1 | A | La acción **no se renderiza**. No hay diálogo de confirmación alcanzable. Mismo trato que S2 |

---

## Bloque 8 — Error-Guessing (riesgo por experiencia)

| ID | Título | Téc. | AC | Capa | Prio | Fixture | Resultado esperado |
|---|---|---|---|---|---|---|---|
| TC-26 | should enforce the same guards when the leave is requested through the agentic AI route | EG-1 | seg. | AGENT + API | P2 | A o B | La IA agéntica llega al mismo RPC `SECURITY DEFINER`. Con sole owner / única membresía debe fallar con `409`, **no** ejecutar el `DELETE`. No hay ruta de bypass |
| TC-27 | should never leave a workspace with zero active owners when two co-owners leave concurrently | EG-3 | seg. | API | P3 | C (2 owners) | En un race de dos co-owners saliendo casi a la vez, uno recibe `409` `sole_owner`. El workspace **nunca** queda con 0 owners activos (BR-8) |
| TC-28 | should reject a malformed workspace id cleanly | EG-4 | — | API | P2 | cookie | UUID con otra capitalización / espacios / formato inválido → `400` o `404` limpio, nunca `500` |

---

## Resumen de cobertura

| Escenario AC | Casos que lo cubren |
|---|---|
| **S1** — confirmación + fallback de activo | TC-12, TC-16, TC-22, TC-23 |
| **S2** — bloqueo sole owner | TC-08, TC-09, TC-10, TC-24 |
| **A** — bloqueo única membresía | TC-07, TC-09, TC-25 |
| **B** — sin cascada + revoca PAT | TC-14, TC-19, TC-20, TC-21 |
| **C** — co-owner puede irse | TC-11, TC-16 |
| Seguridad / contrato (más allá de las ACs) | TC-01, TC-02, TC-03, TC-04, TC-05, TC-06, TC-13, TC-15, TC-17, TC-18, TC-26, TC-27, TC-28 |

**Total: 28 casos** — 16 P1, 10 P2, 2 P3.

Nota de doctrina: **verificar las ACs es el piso, no el techo.** Los 13 casos de "seguridad / contrato" no salen de ninguna AC: salen de los hallazgos de la recon y de las técnicas. Ese es el aporte de la pasada asistida.

---

## Fixtures — estado

| Fixture | Qué es | Estado |
|---|---|---|
| **A** | `Bunkai 3` — el usuario es sole owner + única membresía (los dos bloqueos juntos) | Ya existe |
| **B** | `Fixture B BK-859` — 2do workspace propio. Levanta `last_membership`, aísla `sole_owner` | Ya creado (`7a14b2d9-24fa-481b-821d-50da6ca01491`, 2026-09-10) |
| **C** | B + un 2do `owner` en ese workspace | **Falta.** Difícil: no se puede invitar como `owner`, no hay endpoint para promover. Probablemente `INSERT` por DB. Verificar permisos de `qa_inspector_rw` |
| **D** | Otro usuario invita al nuestro como `member` (variante `admin` para TC-13) | **Falta.** Necesita un segundo usuario que tenga su propio workspace y mande invite |
