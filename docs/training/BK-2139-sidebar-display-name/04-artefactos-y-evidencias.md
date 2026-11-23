# 04 · Artefactos y evidencias

## Artefactos en Jira / Xray (upexgalaxy74, proyecto BK)

| Artefacto | Clave | Estado | Padre |
|---|---|---|---|
| Historia | BK-2139 | QA Approved | BK-85 Account & Settings |
| Tests TC1-TC12 | BK-2425 … BK-2436 | READY | BK-70 QA Test Repository |
| ATS | BK-2438 | Designing (pendiente de ROI) | BK-515 QA Test Artifacts |
| ATP | BK-2439 | Completed | BK-514 QA Master Test Plan |
| ATR | BK-2440 (ambiente staging) | Close | BK-515 QA Test Artifacts |
| Test duplicado | BK-2437 | DEPRECATED | — |

## Resultado por caso

| TC | Qué verifica | Resultado |
|---|---|---|
| TC1 | se ve el nombre guardado | PASSED |
| TC2 | el rol no cambia | PASSED |
| TC3 | el desplegable sigue mostrando el email | PASSED |
| TC4 | el tooltip sigue siendo el email | PASSED |
| TC5 | sin nombre se ve el email | PASSED (débil: falta de nombre de proveedor inferida) |
| TC6 | sin nombre propio se ve el nombre de Google | PASSED |
| TC7 | el nombre propio le gana al de Google | PASSED |
| TC8 | la barra cambia al guardar, sin recargar | PASSED |
| TC9 | al borrar vuelve el email, sin recargar | PASSED |
| TC10 | 80 caracteres se cortan sin romper la barra | PASSED |
| TC11 | el HTML se muestra como texto | PASSED |
| TC12 | el nombre llega desde el servidor | PASSED |

## Evidencias

Carpeta local (no se sube al repo): `.context/PBI/epics/EPIC-BK-85-account-settings/stories/STORY-BK-2139-account-show-the-saved-display-name-in-the-sidebar/evidence/`

| Archivo | Caso | En Xray |
|---|---|---|
| 00 a 08 | smoke, TC1-TC5, TC8-TC12, reversión | sí, adjuntas a cada corrida |
| 09 a 12 | error OAuth de GitHub, TC6, TC7 | no: muestran la cuenta personal |

## Observaciones fuera de la historia

| # | Observación |
|---|---|
| O1 | sin workspace activo, la línea del rol dice "Signed in" |
| O2 | Settings precarga el nombre del proveedor y permite guardarlo como propio (alcance de BK-1949) |
| O3 | un primer login con GitHub terminó en `localhost:3000` con "OAuth state has expired" |
| O4 | en un guardado no se detectó el aviso de confirmación |

## Qué revisar en este checkpoint

- ¿Encuentras cada clave en Jira desde la historia?
- ¿Qué observación llevarías a una charla con el equipo y cuál dejarías anotada?
