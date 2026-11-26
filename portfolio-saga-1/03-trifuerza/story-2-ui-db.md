# Story 2 · UI + DB · BK-2139

> Vigente al 2026-11-25. Recorrido completo: [`docs/training/BK-2139-sidebar-display-name/`](../../docs/training/BK-2139-sidebar-display-name/README.md).

## La historia

**BK-2139** · Account: mostrar el nombre guardado en el bloque de usuario de la barra lateral. El bloque muestra el nombre propio; si no hay, el nombre del proveedor de inicio de sesión (Google, GitHub); si tampoco hay, el email.

| Punto | Resultado |
|---|---|
| Ambiente | staging |
| Resultado | PASSED 12/12, sin defectos |
| Cierre | Ely firmó el DoD ("Meets the minimum comfortably") y pasó la historia a Ready For Release |
| Artefactos | ATP BK-2439 (Completed) · ATS BK-2438 · ATR BK-2440 (Close) · Tests BK-2425 … BK-2436 |

## Por qué esta historia

- Se compararon 4 historias candidatas por tipo de prueba, tamaño y riesgo.
- Se eligió BK-2139: chica, clara, entregada en staging (merge verificado en el repo de la app) y del tipo UI + DB.
- El campo "Acceptance Criteria (Gherkin)" estaba vacío: se refinó dentro de la planificación (8 escenarios), no con shift-left, porque la historia ya estaba construida.

## Qué cubre cada capa

| Capa | Qué se verificó | Casos | Cómo se observó |
|---|---|---|---|
| UI | texto del bloque, rol, tooltip, desplegable, corte a 80 caracteres, HTML como texto | TC1-TC4, TC10, TC11 | página renderizada + capturas |
| UI (estado) | la barra cambia al guardar y al borrar el nombre, sin recargar | TC8, TC9 | una marca puesta en la página antes de guardar sigue después |
| Datos (persistencia) | prioridad nombre propio > nombre del proveedor > email, según lo guardado en la cuenta | TC5-TC7, TC9 | recarga de la página: el nombre llega desde el servidor |
| Servidor | el nombre se resuelve en el servidor, sin pedido extra del navegador | TC12 | el primer HTML ya trae el nombre; los pedidos de carga no lo buscan |

**Límite de la capa DB:** el usuario de base de datos de QA no tiene acceso al esquema `auth`, donde vive el dato (`app_metadata`). La persistencia se confirmó por la página que arma el servidor después de recargar, no por una consulta directa. Firmeza: débil para la capa DB, firme para UI.

## Decisiones que se pueden defender

| Decisión | Por qué |
|---|---|
| 12 casos para 7 criterios | 7 cubren los criterios; 5 suman técnicas (particiones, valores límite, transición de estados, tabla de decisión, adivinanza de errores) sobre los riesgos de la historia |
| TC6 y TC7 con una cuenta de Google real | el nombre del proveedor solo existe con un inicio de sesión OAuth real |
| devolver las dos cuentas a "sin nombre propio" | el usuario de staging es compartido; se verificó al final recargando |
| 4 observaciones (O1-O4) sin bug | quedan fuera de los criterios de BK-2139; anotadas en el ATR para el equipo |

## Bugs

Ninguno. Observaciones fuera de la historia: O1 (sin workspace activo, el rol dice "Signed in"), O2 (Settings precarga el nombre del proveedor; alcance de BK-1949), O3 (un login con GitHub terminó en `localhost:3000` con "OAuth state has expired"), O4 (un aviso de guardado no detectado, no reproducido).
