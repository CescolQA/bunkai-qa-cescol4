# Recorrido BK-2139: nombre guardado en el bloque de usuario de la barra lateral

> Vigente al 2026-11-23. Práctica de la Saga 1 del Dojo (tercera historia). Se revisa cuando cierre la Stage 4 (ROI) de esta historia.

## Cómo leer esta carpeta

1. Empieza por la tabla de resumen de abajo: en una vista sabes qué pasó.
2. Lee los archivos en orden; cada uno cierra con "Qué revisar en este checkpoint".
3. El glosario está al final de este README; los términos aparecen la primera vez con su significado.

## Índice

| Archivo | Qué contiene |
|---|---|
| `01-contexto-y-pedido.md` | por qué esta historia, qué pedía UPEX y cómo se eligió |
| `02-recorrido-paso-a-paso.md` | las cuatro etapas (inicio, planificación, ejecución, reporte) con lo hecho en cada una |
| `03-decisiones-y-correcciones.md` | las decisiones de César, los errores de la IA y cómo se corrigieron |
| `04-artefactos-y-evidencias.md` | claves de Jira/Xray, rutas de evidencia y qué muestra cada una |
| `05-aprendizajes.md` | lo que sirve para la próxima historia y para el trabajo |

## Resumen

| Punto | Resultado |
|---|---|
| Historia | BK-2139 · Account: mostrar el nombre guardado en el bloque de usuario de la barra lateral |
| Ambiente | staging |
| Resultado | PASSED 12/12, sin defectos; Ely firmó el DoD y pasó la historia a Ready For Release |
| Artefactos | ATP BK-2439 (Completed) · ATS BK-2438 (Designing, pendiente de ROI) · ATR BK-2440 (Close) · 12 Tests BK-2425 … BK-2436 |
| Pendiente | Stage 4 (ROI): completar los 5 campos que pide el flujo para cerrar el ATS |
| Observaciones fuera de la historia | 4 (O1 a O4), anotadas en el ATR |

## Glosario mínimo

| Término | Qué es | Ejemplo cotidiano |
|---|---|---|
| ATP | plan de pruebas de aceptación de una historia (qué se va a probar y por qué) | la lista de compras antes de ir al súper |
| ATS | conjunto de casos de prueba de la historia; de él salen las listas del ATP y el ATR | la bolsa donde van todos los productos |
| ATR | ejecución de las pruebas, con el resultado de cada caso | el ticket de la caja con lo que se pagó |
| TC | caso de prueba (un "Test" en Xray) | un producto de la lista |
| Gherkin | formato Given / When / Then para escribir criterios y casos | "dado que tengo hambre, cuando abro la heladera, entonces veo comida" |
| Smoke | prueba rápida de que el ambiente funciona antes de probar a fondo | encender la luz antes de buscar algo en la pieza |
| Trazabilidad | los enlaces que conectan historia, plan, conjunto y ejecución | el hilo que une la receta con cada ingrediente |
| OAuth | iniciar sesión con otra cuenta (Google, GitHub) | entrar a un edificio mostrando el carnet de otra institución |
| ROI | análisis de cuánto conviene automatizar o repetir un caso | decidir si vale la pena comprar un lavavajillas |
