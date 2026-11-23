# 01 · Contexto y pedido

## Por qué esta historia

- Ely (sensei de UPEX) respondió el pedido de certificado de la Saga 1 con una sola acción: "pásame una captura de Mi Desempeño".
- La página marcaba "Todavía en camino": hacían falta **más de 2 historias productivas** (había 2: BK-509 y BK-859).
- La guía "Cómo obtener tu certificado de la Saga 1" (Dojoteca) pide **dos cosas**: (1) veredicto OK en Mi Desempeño = 3 historias distintas en Done o bloqueadas por un defecto abierto, y (2) los entregables de las Clases 0 a 4 en una carpeta `portfolio-saga-1/` del repo.
- La Clase 4 (bugs y gestión de pruebas) es la fila más pesada de la rúbrica (30 de 100 puntos) y pide ATCs en Xray con veredicto ROI; hasta este día había 0 Tests propios en Xray.

## Plan acordado (seis partes)

| # | Parte | Estado al cierre de esta jornada |
|---|---|---|
| 1 | tercera historia | hecha (BK-2139) |
| 2 | ATCs en Xray con veredicto ROI | Tests creados; ROI pendiente |
| 3 | dashboard de defectos | pendiente |
| 4 | retest de BK-1901 | depende del fix de UPEX |
| 5 | `portfolio-saga-1/` | pendiente |
| 6 | pedido formal en el canal | pendiente |

## Cómo se eligió BK-2139

- Se listaron las historias sin asignar en Ready For QA / In Test (8).
- Se compararon 4 por tipo de prueba (UI, UI+DB, UI+DB+API), tamaño y riesgo.
- Se eligió BK-2139: chica, clara, entregada en staging (merge verificado con git), del tipo UI+DB.
- César detectó que el campo "Acceptance Criteria (Gherkin)" estaba vacío (solo la plantilla). Se decidió refinarlo dentro de la planificación, no con shift-left: la historia ya estaba construida y en In Test.

## Qué revisar en este checkpoint

- ¿Queda claro por qué hacía falta una tercera historia y no solo responder a Ely?
- ¿Puedes explicar en una frase por qué no correspondía shift-left en BK-2139?
