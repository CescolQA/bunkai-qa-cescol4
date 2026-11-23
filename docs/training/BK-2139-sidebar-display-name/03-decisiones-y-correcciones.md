# 03 · Decisiones y correcciones

## Decisiones de César

| Momento | Decisión | Por qué |
|---|---|---|
| plan | responder a Ely y armar el plan en paralelo | no quedar esperando |
| elección | BK-2139 | chica y clara; deja tiempo para Xray y el dashboard |
| refinamiento | detectar el Gherkin vacío y refinarlo | completar la historia antes de probar |
| datos AC2 | usar su propia cuenta de Google/GitHub | único camino real a un nombre de proveedor |
| formato | Tests en Gherkin | los criterios ya estaban en Gherkin; varios son candidatos a automatizar |
| datos compartidos | cambiar el nombre del usuario compartido y revertirlo | mismo criterio que usó el equipo al entregar la historia |
| duplicado | deprecar, no borrar | reversible y deja rastro para la auditoría |

## Errores de la IA y su corrección

| Error | Cómo se detectó | Corrección | Aprendizaje |
|---|---|---|---|
| dar la historia por completa mirando solo la descripción | César vio el campo Gherkin vacío | revisar también el campo de criterios | leer todos los campos de criterios antes de opinar |
| proponer shift-left para una historia en In Test | contraste con el estado de entrada de la skill | pasar a la planificación de `/sprint-testing` | el estado de la historia decide la ruta |
| búsqueda JQL con comillas mal armadas | el reintento creó un Test duplicado (BK-2437) | deprecarlo con comentario | verificar lo creado con una búsqueda probada antes de reintentar |
| marca de "sin recarga" con error de sintaxis | la marca volvió vacía | repetir TC8 con la marca bien hecha | una prueba que no puede fallar no prueba nada |
| comando para abrir capturas con la ruta mal escapada | César vio el error de Windows | rehacer el comando | probar con un archivo antes de un lote |

## Qué revisar en este checkpoint

- ¿Qué error de la tabla te parece más fácil de repetir en el trabajo?
- ¿Cuál de tus decisiones defenderías primero ante Ely?
