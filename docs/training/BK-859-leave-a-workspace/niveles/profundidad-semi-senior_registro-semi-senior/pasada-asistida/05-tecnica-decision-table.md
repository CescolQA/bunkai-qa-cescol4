# Checkpoint 4 — Decision Table

> **Qué es**: cuando varias condiciones se combinan para producir un resultado, se arma una tabla con todas las combinaciones relevantes y su salida. Fuerza a no olvidar ninguna.
> **Disparador**: 2 o más condiciones interactúan. Acá hay 5 condiciones encadenadas (los 4 guards + el estado del workspace activo).
> **Para qué acá**: consolida EP + BVA en una sola vista y expone si falta alguna combinación.

---

## 1. Condiciones

| Cód. | Condición | Valores posibles |
|---|---|---|
| C1 | Forma de autenticación | `sin-sesión` / `PAT` / `cookie` |
| C2 | ¿Tiene fila `status='active'` en el target? | sí / no |
| C3 | ¿Tiene 2 o más membresías activas en total? | sí / no |
| C4 | ¿Es `role='owner'` del target? | sí / no |
| C5 | Si C4 = sí, ¿hay 1+ otro owner activo? | sí / no / (n/a si C4=no) |

El orden de evaluación sigue el orden de los guards del RPC (recon 2.1). En cuanto una condición corta, las siguientes no importan (`-`).

---

## 2. Tabla de decisión

| Regla | C1 | C2 | C3 | C4 | C5 | Resultado | HTTP | Escenario AC | Fixture |
|---|---|---|---|---|---|---|---|---|---|
| **R1** | `sin-sesión` | - | - | - | - | `not_authenticated` | `401` | (implícito, seguridad) | — |
| **R2** | `PAT` | - | - | - | - | `forbidden` (cookie-only) | `403` | (implícito, contrato) | B + PAT |
| **R3** | `cookie` | no | - | - | - | `not_a_member` | `404` | (implícito) | cualquiera + WS ajeno |
| **R4** | `cookie` | sí | no | - | - | `last_membership` | `409` | **A** (única membresía) | A |
| **R5** | `cookie` | sí | sí | sí | no | `sole_owner` | `409` | **S2** (sole owner) | B |
| **R6** | `cookie` | sí | sí | sí | sí | leave OK, queda el otro owner | `200` | **C** (co-owner) | C |
| **R7** | `cookie` | sí | sí | no | n/a | leave OK (member / admin / viewer) | `200` | **S1** / **B** | D |

7 reglas. Cubren todas las combinaciones **alcanzables** dado que los guards se evalúan en orden.

### Combinaciones que la tabla NO lista, y por qué

| Combinación | Por qué se omite |
|---|---|
| C1=`cookie`, C2=sí, C3=no, C4=sí, C5=no (única membresía + sole owner) | Alcanzable como estado, pero el guard 3 (C3) corta primero → cae en **R4** (`last_membership`). No es una regla nueva. Es exactamente el caso BVA-5 |
| C1=`cookie`, C2=sí, C3=no, C4=no | Guard 3 corta → **R4**. El rol ya no importa |
| C5 con 2, 3, ... otros owners | Equivale a C5=sí. BVA ya explicó que "lejos del borde" no agrega |

---

## 3. Efectos colaterales del `200` (se prueban sobre R6 y R7)

El `200` no es un único resultado: dispara varios efectos que hay que asertar por separado.

| Efecto | Dónde se valida | Caso relacionado |
|---|---|---|
| La fila de `workspace_members` se borra (hard delete) | DB | ST-1 / ST-2 |
| Si el target era el activo: nuevo activo = membership restante más vieja + cookie `bk_active_ws` rotada | Response body + cookie + UI | ST-8, BVA-7 |
| El PAT con scope del target se revoca | DB (`revoked_at`) + usar el PAT → `401` | ST-11 |
| El contenido autorado (ATCs, US) queda intacto y el que se fue deja de verlo | DB + intentar `GET` como ex-miembro → `403`/`404` | EP-16 |
| El otro owner (en R6) conserva privilegios | API como el otro owner tras el leave | EP-9 |

---

## 4. Pairwise — por qué NO se aplica

> Se documenta la decisión, como pide la doctrina de diseño ("log the reduction").

Pairwise sirve cuando hay **3 o más factores combinables libremente** y probar todas las combinaciones explota. Acá los factores (C1–C5) **no son libres**: los guards se evalúan en cadena y cada uno, al cortar, vuelve irrelevantes a los siguientes. El espacio real de combinaciones alcanzables ya está **completo con 7 reglas**. Aplicar Pairwise no reduciría nada y ocultaría el encadenamiento. **Técnica descartada con fundamento.**

---

## Qué revisar en este checkpoint

- [ ] Las 5 condiciones (C1–C5) están en el orden de evaluación de los guards
- [ ] Cada una de las 7 reglas mapea a un código HTTP y, cuando corresponde, a un escenario de AC
- [ ] Las combinaciones omitidas tienen una razón escrita (guard anterior corta primero)
- [ ] Los efectos colaterales del `200` están listados como asserts separados, no como "y devuelve 200"
- [ ] La decisión de descartar Pairwise quedó justificada
