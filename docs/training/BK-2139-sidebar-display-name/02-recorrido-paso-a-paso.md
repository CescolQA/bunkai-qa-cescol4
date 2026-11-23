# 02 · Recorrido paso a paso

## Etapa 0 · Inicio de sesión de pruebas

| Paso | Qué se hizo | Para qué |
|---|---|---|
| 1 | asignar BK-2139 y pasarla a In Test (con OK) | tomarla para que nadie más la agarre |
| 2 | chequeo previo: staging responde, modalidad Xray, sin sesión anterior | no planificar contra un ambiente caído |
| 3 | sincronizar la historia desde Jira a la carpeta local | leer criterios y comentarios con todos los campos |
| 4 | leer el código en la rama `staging` del repo de la app | confirmar cómo funciona antes de diseñar casos |
| 5 | explicar la historia y esperar el OK | asegurar que lo entendido coincide con lo pedido |

## Etapa 1 · Planificación

| Paso | Qué se hizo |
|---|---|
| 1 | triage: sin veto; riesgo 8 (alto) → plan completo |
| 2 | factibilidad de datos por criterio; AC2 necesitaba una cuenta de Google o GitHub |
| 3 | 8 escenarios Gherkin (7 de los criterios + 1 inferido, marcado para confirmar) |
| 4 | 12 casos: 7 cubren los criterios, 5 van más allá (técnicas: particiones, valores límite, transición de estados, tabla de decisión, adivinanza de errores) |
| 5 | formato de los Tests: Gherkin (elegido por César) |
| 6 | escrituras con OK: campo Gherkin, 12 Tests, ATS, ATP, ATR con ambiente staging |
| 7 | chequeo de trazabilidad: 4/4 |

## Etapa 2 · Ejecución

| Paso | Qué se hizo |
|---|---|
| 1 | smoke: login por el formulario, carga sin errores de consola → GO |
| 2 | TC1-TC5 y TC8-TC12 con el usuario compartido de staging (con OK para cambiar su nombre y devolverlo al final) |
| 3 | prueba de "sin recarga": una marca en la página antes de guardar que sigue después |
| 4 | TC6-TC7 con la cuenta de Google de César (él hizo el login) |
| 5 | devolver las dos cuentas a "sin nombre propio" y verificarlo recargando |

## Etapa 3 · Reporte

| Paso | Qué se hizo |
|---|---|
| 1 | cuerpo del ATR con resultados, datos usados, cómo se observó cada caso y observaciones |
| 2 | 12 corridas en PASSED con comentario y capturas (las de la cuenta personal quedaron locales) |
| 3 | cierre del ATR y del ATP; el ATS no cerró por un validador del flujo (pide datos de ROI) |
| 4 | comentario de QA en la historia y pase a QA Approved |
| 5 | Ely revisó el ATR, firmó el DoD ("Meets the minimum comfortably") y pasó la historia a Ready For Release |

## Qué revisar en este checkpoint

- ¿Puedes nombrar qué artefacto se crea en cada etapa?
- ¿Por qué el smoke va antes que cualquier caso?
