# Checkpoint 2 — Boundary Value Analysis (BVA)

> **Qué es**: los errores se juntan en los **bordes** de las particiones, no en el medio. BVA prueba justo el valor límite y los valores inmediatamente a cada lado.
> **Disparador**: hay un rango, un límite, una longitud o una ventana de fechas. Acá los límites son **contadores** (cantidad de membresías, cantidad de owners).
> **Para qué acá**: "Leave a workspace" no tiene inputs numéricos de usuario, pero los guards 3 y 4 comparan **conteos** contra un umbral. Ahí hay bordes.

---

## 1. Borde 1 — Cantidad de membresías activas del llamador (guard 3)

Condición del guard: se corta si `total de membresías status='active' <= 1`.

El umbral es **1**. El borde está entre 1 (corta) y 2 (pasa).

| Valor | Lado del borde | Resultado esperado | Nota |
|---|---|---|---|
| 0 membresías | Por debajo | No alcanzable en la práctica (para llamar al endpoint tenés que estar en algún workspace), pero conceptualmente cae en `last_membership`. Se documenta, no se prueba | — |
| **1 membresía** | **El umbral** | `409` `last_membership` | Fixture A |
| **2 membresías** | Primer valor que pasa | Pasa el guard 3 (después lo puede cortar el guard 4 si es sole owner del target) | Fixture B |
| 3+ membresías | Lejos del borde | Igual que 2, sin diferencia | No agrega valor probar 3, 4, 5... |

**Casos BVA de este borde:**

| Caso | Valor | Fixture | Esperado |
|---|---|---|---|
| BVA-1 | 1 membresía | A | `409` `last_membership` |
| BVA-2 | 2 membresías, dejando uno donde NO es sole owner | D (o C) | `200` — pasa el guard, se va bien |

---

## 2. Borde 2 — Cantidad de *otros* owners activos en el target (guard 4)

Condición del guard: se corta si `role='owner'` **y** `count(otros owners activos) = 0`.

El umbral es **0**. El borde está entre 0 (corta) y 1 (pasa).

| Valor | Lado del borde | Resultado esperado |
|---|---|---|
| **0 otros owners** | **El umbral** | `409` `sole_owner` (siempre que el llamador sea `owner`) |
| **1 otro owner** | Primer valor que pasa | `200` — co-owner puede irse, queda 1 owner |
| 2+ otros owners | Lejos del borde | Igual que 1, sin diferencia |

**Casos BVA de este borde:**

| Caso | Valor | Fixture | Esperado |
|---|---|---|---|
| BVA-3 | 0 otros owners, llamador es owner | B (dejando el workspace propio con 2+ membresías totales) | `409` `sole_owner` |
| BVA-4 | 1 otro owner activo | C | `200`, el workspace queda con 1 owner |

---

## 3. Borde combinado — el orden de los guards 3 y 4

Este es el borde más interesante y el que la intuición se saltea.

Un usuario que tiene **exactamente 1 membresía** y es **sole owner** de ese workspace cruza los dos bordes a la vez. ¿Qué error gana?

Según el orden del RPC (recon, sección 2.1): **guard 3 antes que guard 4**. Gana `last_membership`.

Para ver `sole_owner` **puro** hay que estar del lado "pasa" del borde 1 (2+ membresías) y del lado "corta" del borde 2 (0 otros owners). Eso es exactamente el **Fixture B dejando el workspace propio**.

| Caso | Estado | Fixture | Esperado | Qué verifica |
|---|---|---|---|---|
| BVA-5 | 1 membresía + sole owner | A | `409` **`last_membership`** (NO `sole_owner`) | El orden de precedencia de los guards |
| BVA-6 | 2 membresías + sole owner del target | B | `409` **`sole_owner`** | Que el guard 4 sí actúa cuando el 3 ya pasó |

---

## 4. Borde de ordenamiento — elección del nuevo workspace activo (H3)

Cuando dejás tu workspace activo, el nuevo activo es la **membership restante más vieja** por `joined_at asc`.

El borde acá es el **empate de `joined_at`**: si dos memberships restantes tienen el mismo timestamp exacto, ¿cuál gana? El contrato no lo especifica.

| Caso | Estado | Esperado | Nota |
|---|---|---|---|
| BVA-7 | 2 memberships restantes con `joined_at` distinto | El nuevo activo es la de `joined_at` menor | Camino feliz del ordenamiento |
| BVA-8 | 2 memberships restantes con `joined_at` idéntico (mismo segundo) | **Comportamiento no especificado.** Verificar que al menos es **determinístico** (misma entrada → mismo resultado siempre) | Difícil de montar. Si no se puede provocar el empate, se deja como pregunta para Dev |

---

## Qué revisar en este checkpoint

- [ ] Los dos contadores de los guards (membresías, otros owners) tienen su borde identificado: umbral 1 y umbral 0
- [ ] Para cada borde hay un caso en el valor que corta y otro en el primer valor que pasa
- [ ] BVA-5 vs BVA-6 dejan explícito que el **orden de los guards** cambia qué `409` se ve
- [ ] No se probaron valores "lejos del borde" (3, 4, 5 membresías) porque no agregan información
- [ ] El empate de `joined_at` (BVA-8) quedó anotado como pregunta para Dev si no se puede montar
