# Práctica: BK-859 "Leave a workspace" (sprint-testing)

Espejo de la práctica de shift-left de BK-509, ahora sobre sprint-testing.
Ticket: BK-859 (clon de práctica de BK-90), Epic BK-85, Sprint 4.

> **Estado: CERRADA (2026-09-10).** La práctica se da por terminada en el paso 7.
> El paso 8 no se ejecuta. Los fixtures C y D no se montaron y los casos que
> dependen de ellos quedan sin correr. Es una decisión de alcance, no un bloqueo:
> el objetivo de entrenamiento (comprender, aplicar, correr y comparar
> `/sprint-testing` sobre una historia real) quedó cubierto con lo hecho.

## Plan de 8 pasos

| Paso | Qué | Estado |
|---|---|---|
| 1 | Entorno | hecho |
| 2 | Pull de contexto de BK-859 | hecho |
| 3 | Brief de contexto de negocio acotado | hecho - `business-context-brief.md` |
| 3.5 | Rampa de arranque + reconocimiento in-app | hecho - `rampa-de-arranque.md` + `modelo-de-roles-y-membership.md` |
| 4 | **Pasada ciega** (a mano, sin IA) | hecho - `pasada-ciega-completada.md` (sellada en commit 7d01f4d) |
| 5 | Pasada asistida (con el doc sellado + técnicas) | hecho - carpeta `pasada-asistida/` (README + 4 checkpoints de técnica + matriz de 28 casos + comparativa ciega/asistida) |
| 6 | Fixtures + exploratoria hands-on | parcial (cerrado por alcance) - fixtures A y B hechos. Ejecución: 7 casos PASS + 2 defectos hallados (DEF-1, DEF-2) en `pasada-asistida/08-ejecucion-fixtures-A-B.md`. Fixtures C y D NO se montaron (decisión de César); los 12 casos que dependen de ellos quedan fuera |
| 7 | Comparativa manual vs asistida | hecho - `pasada-asistida/07-comparativa-ciega-vs-asistida.md` (cerrado; el testing real se cita como respaldo) |
| 8 | Marcar real vs simulado en Jira | no se ejecuta - práctica cerrada por decisión de alcance (2026-09-10) |

DEF-1 y DEF-2 quedan como hallazgos de ejercicio: comentados en la historia,
sin filear como defects formales. No se avanza más sobre ellos.

## Archivos de contexto (este folder)

Se leen antes de la pasada ciega. Idioma castellano, identificadores textuales.

- `business-context-brief.md` - referencia de negocio (corregida con hallazgos del reconocimiento)
- `rampa-de-arranque.md` - checklist de arranque + hallazgos del reconocimiento in-app + queries de DB
- `modelo-de-roles-y-membership.md` - roles / estados / formas de membership / fixtures + primer de "fixture"
- `../bunkai-capas-e-integraciones-para-qa.md` - **compartido**. Mapa de capas (UI / API / RPC / DB / RLS / agéntica) + glosario en criollo. Lente para leer los dos docs de reconocimiento
- `reconocimiento-hallazgos-SELLADO.md` - detalle de RPC y contrato de API. **NO abrir hasta terminar el paso 4** (ya terminado)
- `reconocimiento-hallazgos-2-lenguaje-simple.md` - **Documento 2**. Mismo contenido que el sellado, reescrito en lenguaje más llano. Para comparar cuál se entiende mejor
- `evidence/recon-01..05.png` - capturas del reconocimiento (la carpeta `evidence/` está en `.gitignore` repo-wide: son locales, no se versionan; los hallazgos que sostienen sí están en los `.md`)

> El contexto Jira-sincronizado (`story.md`, `acceptance-criteria.md`, `scope.md`, `implementation-plan.md`, etc.) vive en `.context/PBI/epics/EPIC-BK-85-account-settings/stories/STORY-BK-859-tms-workspace-leave-a-workspace/` y NO se versiona (cache de sync). Los archivos de esta carpeta sí se versionan.

## Archivos de esta práctica (este folder)

- `pasada-ciega.html` - **paso 4, superficie principal para llenar**. Formulario local: se abre con doble click (file://), autoguarda en `localStorage`, y exporta `pasada-ciega-completada.md` + `pasada-ciega.json` con los botones de la barra inferior. Sin conexión, sin dependencias.
- `pasada-ciega.md` - mismo cuestionario en texto plano, por si preferís tipear markdown directo. Espejo, no obligatorio.
- `pasada-ciega-completada.md` - lo que exporta el HTML cuando terminás. Es lo que se lee para el comparativo del paso 5/7.
- `pasada-asistida/` - **paso 5, entregable**. Carpeta con índice (`README.md`), un archivo por técnica (`02`..`05`, cada uno = un checkpoint), la matriz consolidada de 28 casos (`06-matriz-de-casos.md`) y la comparativa ciega vs asistida (`07`, insumo del paso 7). Separado en archivos cortos a propósito, para leerlo por partes.

## Paso 6 - Fixtures a mano (entrenamiento API)

Antes de que la IA arme los fixtures por script, Cesar hace **el fixture B a mano con Postman**, como repaso de API. Procedimiento completo: `fixture-b-postman.md`.

- **Fixture B**: 2do workspace propio vía `POST /api/v1/workspaces` (body `name` + `slug`). Deja al usuario con 2 membresías activas, así el guard `last_membership` deja de aplicar y queda aislado `sole_owner`.
- **Cambio vs plan viejo**: crear workspace acepta `bearerAuth`, no es cookie-only (solo "leave" lo es). El flujo es `POST /api/v1/auth/signin` (email+password → PAT) y después `POST /api/v1/workspaces` con `Authorization: Bearer <pat>`. Sin cookies.
- Contrato leído del OpenAPI de staging el 2026-09-09 (base URL `https://staging-upexbunkai.vercel.app`).
