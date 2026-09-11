# Checkpoint 1 — Equivalence Partitioning (EP)

> **Qué es**: agrupar las entradas posibles en clases donde el sistema se comporta igual. Probás **un representante por clase**, no todas las entradas.
> **Disparador**: se aplica siempre. Es la técnica base.
> **Para qué acá**: "Leave a workspace" no tiene campos de formulario, pero sí tiene **dimensiones de contexto** (quién llama, en qué estado está, qué rol tiene). Cada dimensión se parte en clases.

---

## 1. Dimensiones y particiones

Cada fila es una dimensión de entrada. Cada partición es una clase de equivalencia: `[V]` válida (deja avanzar), `[I]` inválida (corta con error).

### D1 — Forma de autenticación

| Partición | Clase | Resultado esperado |
|---|---|---|
| Sin sesión (ni cookie ni PAT) | `[I]` | `401` `not_authenticated` |
| Sesión por **cookie** de navegador válida | `[V]` | Avanza a los guards siguientes |
| Autenticado por **PAT** (Bearer token) | `[I]` | `403` — el endpoint es cookie-only |

### D2 — Membership del llamador en el workspace target

| Partición | Clase | Resultado esperado |
|---|---|---|
| El workspace no existe (UUID inventado o borrado) | `[I]` | `404` |
| Existe, pero el llamador **no** tiene fila ahí | `[I]` | `404` `not_a_member` |
| Tiene fila con `status='invited'` (invitación sin aceptar) | `[I]` | `404` — no es "miembro activo" |
| Tiene fila con `status='suspended'` | `[I]` | `404` — la fila existe pero no está `active` |
| Tiene fila con `status='active'` | `[V]` | Avanza |

### D3 — Cantidad de membresías activas del llamador (en toda la instancia)

| Partición | Clase | Resultado esperado |
|---|---|---|
| Exactamente 1 (este workspace es el único) | `[I]` | `409` `last_membership` |
| 2 o más | `[V]` | Avanza |

### D4 — Rol del llamador en el target + otros owners

| Partición | Clase | Resultado esperado |
|---|---|---|
| `role='owner'` y **0** otros owners activos | `[I]` | `409` `sole_owner` |
| `role='owner'` y **1+** otros owners activos (co-owner) | `[V]` | `200` — puede irse |
| `role='admin'` | `[V]` | `200` — `admin` cuenta como no-owner para el guard (H5) |
| `role='member'` | `[V]` | `200` |
| `role='viewer'` | `[V]` | `200` |

### D5 — ¿El target es el workspace activo del llamador?

| Partición | Clase | Resultado esperado |
|---|---|---|
| Sí, el target es el activo | `[V]` | `200` + response trae `newActiveWorkspaceId`/`Name` re-resueltos + rota `bk_active_ws` |
| No, el activo es otro | `[V]` | `200` + el activo no cambia |

### D6 — PAT del llamador con scope del workspace target

| Partición | Clase | Resultado esperado |
|---|---|---|
| Tiene un PAT activo con scope del target | `[V]` | El PAT queda `revoked_at = now()` tras el leave (H4) |
| No tiene ningún PAT de ese workspace | `[V]` | Sin efecto sobre tokens |
| Tiene un PAT de **otro** workspace | `[V]` | Ese PAT **no** se toca |

### D7 — Contenido autorado por el que se va

| Partición | Clase | Resultado esperado |
|---|---|---|
| Autoró ATCs / user stories en el workspace | `[V]` | El contenido queda intacto; el que se fue deja de verlo (AC S1/B) |
| No autoró nada | `[V]` | Sin diferencia observable en contenido |

---

## 2. Casos que salen de EP

Un caso por clase que no esté ya cubierta por otra. Numeración `EP-n` (se consolida con ID final en `06`).

| Caso | Dimensión / clase | Precondición (fixture) | Resultado esperado |
|---|---|---|---|
| EP-1 | D1 sin sesión | — | `401` |
| EP-2 | D1 por PAT | Fixture B + PAT | `403` |
| EP-3 | D2 workspace inexistente | Sesión cookie válida | `404` |
| EP-4 | D2 no es miembro | Cookie válida + UUID de un workspace ajeno | `404` |
| EP-5 | D2 fila `invited` | Usuario con invitación sin aceptar | `404` |
| EP-6 | D2 fila `suspended` | Usuario con membership suspendida | `404` |
| EP-7 | D3 única membresía | **Fixture A** (Bunkai 3, sole owner + única membresía) | `409` `last_membership` |
| EP-8 | D4 sole owner con 2+ membresías | **Fixture B** (dejando el 2do workspace donde es único owner) | `409` `sole_owner` |
| EP-9 | D4 co-owner | **Fixture C** (2 owners en el workspace) | `200`, queda el otro owner |
| EP-10 | D4 member no-owner | **Fixture D** (invitado como `member`) | `200` |
| EP-11 | D4 admin | Fixture D variante `admin` | `200` (no dispara `sole_owner`) |
| EP-12 | D5 dejar el activo | Fixture C o D, con el target seteado como activo | `200` + nuevo activo + cookie rotada |
| EP-13 | D5 dejar un no-activo | Fixture C o D, con OTRO workspace como activo | `200` + activo sin cambio |
| EP-14 | D6 PAT del target se revoca | Fixture D + PAT con scope del target | Tras leave, el PAT da `401` al usarlo |
| EP-15 | D6 PAT de otro workspace intacto | Fixture D + PAT de otro workspace | Ese PAT sigue funcionando tras el leave |
| EP-16 | D7 contenido intacto | Fixture D + ATCs autorados por el usuario en el target | Tras leave, los ATCs siguen en el workspace; el usuario ya no los ve |

---

## Qué revisar en este checkpoint

- [ ] Cada dimensión (D1–D7) tiene al menos una partición válida y las inválidas que correspondan
- [ ] Ninguna partición inválida quedó sin un caso `EP-n`
- [ ] Las particiones de D3 y D4 dejan claro que necesitan **fixtures distintos** (A para `last_membership`, B para `sole_owner`)
- [ ] EP no intenta cubrir los bordes numéricos (eso es BVA, checkpoint 2) ni el orden temporal (eso es State-Transition, checkpoint 3)
- [ ] Los casos `[V]` de D5, D6 y D7 no son "de relleno": cada uno verifica un efecto colateral distinto del `200` (nuevo activo, revoca PAT, contenido intacto)
