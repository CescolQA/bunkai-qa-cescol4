# BK-509 — Comparación de las tres fases

Análisis ciego (humano) vs. refinamiento asistido por IA vs. resolución real de producción (2026-05/06).

**Convergencia de riesgo**: las tres fuentes, de forma independiente, calificaron la historia como **HIGH**. Ninguna la subestimó.

## Tabla comparativa — ¿quién detectó qué?

| Punto real de la historia | Fase 1 — Ciego (humano) | Fase 2 — Asistido por IA | Proceso real (may/jun 2026) |
|---|---|---|---|
| **BK-54** — slugs reservados no rechazados (ej. nombre "New") | No mencionado | **Detectado** — encontró la lógica en código, ya corregida al momento de este ejercicio | **Detectado** — bug real, encontrado en ejecución |
| **BK-55** — ruta de detalle del proyecto sin scope de workspace | Parcial — mencionó el chequeo de membresía a nivel de base de datos, no esta ruta puntual | Parcial — cubrió el aislamiento cross-workspace en general, no esta ruta específica (fuera del alcance del endpoint analizado) | **Detectado** — bug real |
| **BK-56** — nombres no-Latinos (CJK/cirílico) rechazados | No mencionado | **Detectado** — predijo el mecanismo exacto (slug con hash de respaldo) que hoy resuelve este bug | **Detectado** — bug real, ya corregido en el código actual |
| "Nombre debe tener ≥1 carácter alfanumérico" sin AC que lo cubra | Detectado | Detectado | Detectado |
| Mismo slug permitido en dos workspaces distintos | Intuido | Convertido en caso de test explícito | AC-10 real |
| Rol `viewer` — ¿mismo código de error que "no miembro"? | No mencionado | Detectado, marcado como pregunta bloqueante | Nunca se cerró del todo — quedó "DEFERRED" en el resultado real |
| Crítica: las ACs mezclan nivel técnico/API con nivel funcional | **Único hallazgo tuyo** — ninguna otra fuente lo señaló | No señalado | No señalado |

## Lectura objetiva

- La IA predijo, sin haber visto el historial, el área exacta de **dos de los tres** bugs reales (BK-54 y BK-56) — solo por leer el código y los mapas de negocio.
- El tercer bug (BK-55) escapó a la IA porque el subagente se limitó al endpoint de creación; la ruta de detalle del proyecto quedó fuera del alcance que se le dio.
- Vos aportaste algo que ni la IA ni el proceso real de mayo escribieron: la crítica de que las ACs mezclan nivel técnico y funcional — una observación de *proceso*, no de comportamiento puntual.
- Ningún método, por sí solo, cubrió el 100%. La combinación — ojo humano para el proceso, IA para la profundidad de código — es lo que más se acerca a la cobertura real.

## Fuentes

- `docs/training/BK-509-create-project-in-workspace/phase1-blind-analysis.md`
- `.context/PBI/epics/EPIC-BK-7-project-module-hierarchy/stories/STORY-BK-509-tms-project-create-a-project-inside-a-workspace/shift-left-refinement.md`
- `.context/PBI/epics/EPIC-BK-7-project-module-hierarchy/stories/STORY-BK-509-tms-project-create-a-project-inside-a-workspace/acceptance-test-plan.md` + `acceptance-test-results.md` (sincronizados de Jira)

Generado el 2026-08-26 como cierre de la práctica shift-left sobre BK-509.
