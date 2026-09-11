# BK-859 "Leave a workspace" — Pasada asistida (paso 5)

> Práctica de sprint-testing. Espejo local de la etapa **test-design** del skill `/sprint-testing` (Stage 1, Planning).
> Nada de esto se sube a Jira. Es material de estudio.
> Idioma castellano por convención de entrenamiento. Identificadores, enums, códigos de error y nombres de endpoint van textuales.

---

## Qué es esta pasada

En la **pasada ciega** (paso 4) diseñaste pruebas solo con el brief de negocio, sin ver el detalle técnico.

En esta **pasada asistida** rehacés el diseño, pero ahora con:

- `../reconocimiento-hallazgos-SELLADO.md` — el contrato real de la API y el RPC de base de datos
- `../modelo-de-roles-y-membership.md` — las 4 formas de membership y los guards
- las técnicas formales de diseño de pruebas, aplicadas una por una

El objetivo no es "más casos". Es **casos mejor fundados**: cada uno nace de una técnica con un disparador claro, no de intuición.

---

## Cómo leer esta carpeta

Los archivos están numerados. Leelos en orden la primera vez.

| Archivo | Qué contiene | Checkpoint |
|---|---|---|
| `01-punto-de-partida.md` | Las 5 ACs de BK-859 en tabla + los hallazgos de la recon que cambian el diseño | 0 |
| `02-tecnica-equivalence-partitioning.md` | Particiones de equivalencia (EP). Agrupa entradas que el sistema trata igual | 1 |
| `03-tecnica-boundary-value-analysis.md` | Análisis de valores límite (BVA). Prueba los bordes de los contadores | 2 |
| `04-tecnica-state-transition.md` | Transición de estados. La membership, el workspace activo y el PAT como máquinas de estado | 3 |
| `05-tecnica-decision-table.md` | Tabla de decisión. Las 5 condiciones cruzadas contra el resultado | 4 |
| `06d-matriz-de-casos-v4.md` | **El entregable central. Versión definitiva.** Documento autónomo (sin historial de versiones dentro): criterios de aceptación primero, títulos de caso en castellano con la convención, columna `Naturaleza` por caso, Parte 3 como índice de prioridad en tablas, Parte 4 con Vista A (por AC) + Vista B (por dimensión de calidad: técnica / capa / naturaleza / prioridad, cada una un índice completo) | — |
| `06-matriz-de-casos.md` · `06b-...-v2.md` · `06c-...-v3.md` | Borradores previos (histórico). No usar. `06d` los reemplaza | — |
| `07-comparativa-ciega-vs-asistida.md` | **Cierre de la comparación.** Trabajo manual (pasada ciega) vs. pasada asistida, con el respaldo del testing real donde aporta. Tabla de diferencias, qué acertó cada una, DEF-1/DEF-2, lecturas | — |
| `08-ejecucion-fixtures-A-B.md` | **Ejecución real (parcial).** Ronda 1: 6 casos PASS. Ronda 2: TC-08 por código + hallazgos DEF-1 (guard cuenta membresías de workspaces borrados) y DEF-2 (business-rules de BK-512 desactualizado) | — |

Cada archivo de técnica cierra con un bloque **"Qué revisar en este checkpoint"**. Si vas con prisa, leé la matriz (`06`) y usá esos bloques como lista de verificación.

---

## Resumen ejecutivo

| Dato | Valor |
|---|---|
| Nivel de riesgo | **ALTO** (coincide con la pasada ciega) |
| Escenarios de AC | 5 (S1 confirmación, S2 bloqueo sole owner, A bloqueo única membresía, B sin cascada + revoca PAT, C co-owner puede irse) |
| Técnicas aplicadas | EP, BVA, State-Transition, Decision Table, Error-Guessing |
| Técnica descartada | Pairwise — los factores no son combinables libres, el orden de guards los serializa (ver `05`) |
| Casos de prueba diseñados | 28 — 16 P1, 10 P2, 2 P3 (ver `06-matriz-de-casos.md`) |
| Capas | API (núcleo), UI (confirmación + estados bloqueados), DB (hard delete + revoca PAT) |
| Fixtures necesarios | A (ya existe), B (ya creado), C (co-owner — falta, difícil), D (member invitado — falta) |
| Hallazgo para elevar como *improvement* | Los dos `409` (`last_membership` y `sole_owner`) no tienen un `code` dedicado en el `ErrorEnvelope`; hay que distinguirlos por `message`/`details` |

---

## Glosario mínimo

| Término | En una línea |
|---|---|
| RPC | Función de base de datos (Postgres) que la API llama. Acá: `bunkai_leave_workspace` |
| Guard | Chequeo previo dentro del RPC que corta la operación con un error si no se cumple |
| SQLSTATE | Código de error que devuelve Postgres (ej. `45212`). La API lo traduce a un HTTP status |
| Membership | Fila en `workspace_members`: relaciona un usuario con un workspace, con un `role` y un `status` |
| PAT | Personal Access Token. Credencial de API con scope de un workspace |
| Cookie-only | El endpoint solo acepta sesión por cookie de navegador. Un PAT recibe `403` |
| Fixture | Estado montado a propósito antes de una prueba, para que el resultado sea repetible |
| Partición de equivalencia | Grupo de entradas que el sistema procesa de la misma forma. Se prueba una por grupo |
| Valor límite | El borde entre dos particiones (ej. "1 membresía" vs "2 membresías"). Ahí se concentran los errores |
