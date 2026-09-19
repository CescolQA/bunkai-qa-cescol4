# Comunicación estratégica del entrenamiento

> **Nivel de referencia (dial I-7):** `profundidad semi-senior · registro semi-senior` (default).
> Historial de decisiones descartadas → `CHANGELOG.md`. Este documento describe la base actual, no cómo se llegó a ella.

## Objetivo

Convertir lo entrenado en este repo en una narrativa comunicable hacia afuera
(repos de GitHub, sitio personal, LinkedIn) sin perder rigor técnico ni
inflar lo hecho.

## Los 4 pilares del entrenamiento

1. **Rol analista (base)** — actualización de lo que ya se sabía como analista
   funcional (junior) y analista de pruebas (semi-senior), sin IA de por medio.
2. **Rol + IA asistida** — integrar las responsabilidades del rol con
   asistencia de IA: ingeniería de contexto, harness, prompt engineering,
   onboarding de CLIs y MCPs, uso de Claude Code más allá de un chat simple.
3. **Ecosistema de agentes orquestados** — próximo núcleo: agentes que
   ejecutan tareas encadenadas vía skills, cubriendo todo el circuito de
   responsabilidad del rol, no solo asistencia puntual.
4. **Experiencia, criterio y aprendizaje propio** — la voz propia de César:
   qué le aportó de verdad cada skill, no como categoría de proceso sino
   como testimonio. No rota como titular de un deck: va presente en TODOS
   los decks de skill como capa personal, encima del pilar que ese deck
   destaque.

## Núcleo elegido — rol híbrido a través de las skills

Hilo central: un **rol híbrido** (analista funcional + analista QA), entre
el criterio humano y la asistencia de IA, demostrado skill a skill (la
lista de skills no está cerrada a un número fijo):

| Skill | Qué demuestra del rol | Evidencia en este repo |
|---|---|---|
| `project-discovery` | Lectura de arquitectura + negocio desde cero, sin guía previa | Reversa completa de Bunkai TMS (2026-08-17) |
| `shift-left-testing` | Ojo funcional: refinar ACs, detectar ambigüedad antes de que exista bug | Práctica BK-509 (cerrada, comparación de 3 vías) |
| `sprint-testing` | Ejecución QA real: diseño de casos, fixtures, hallazgos | Práctica BK-859 (cerrada, pasos 1-7, 2 defectos hallados) |

## Organización de los archivos

| Ruta | Qué define |
|---|---|
| `fundamento.md` | **la fuente**: qué se comunica y por qué. Todo deriva de acá |
| `README.md` (este) | la forma: temas, paleta, reglas de deck |
| `CHANGELOG.md` | decisiones descartadas, con su motivo |
| `presentaciones/` | decks. Termómetro de tono y fuente para recortar |
| `piezas/linkedin/` · `piezas/sitio/` | los textos que se publican afuera |

## Canales destino

Dos canales, decididos 2026-09-19. Mensaje por canal definido en `fundamento.md` §6.

| Canal | Rol | Tema visual |
|---|---|---|
| LinkedIn | apertura: trae lectores, una idea por pieza | B — contraste |
| Sitio personal `cescolqa.github.io` | profundidad: sostiene lo que el post afirma | C — híbrido |

## Paleta de marca (fija)

La del LinkedIn profesional de César. Única paleta para todo lo que se
publique — decks, LinkedIn, GitHub:

| Color | Hex | Rol |
|---|---|---|
| Blanco | `#FFFFFF` | fondo |
| Navy | `#1D0847` | tinta principal — títulos, bordes, fondos sólidos de énfasis |
| Lavanda | `#9486A9` | acento — kickers, resaltados, bordes finos |
| Gris | `#AFB4B3` | texto muted — footers, etiquetas, separadores. Nunca texto de lectura principal (no tiene contraste suficiente) |

El archivo `presentaciones/assets/knowledge-arch-blueprint.css` mantiene el
nombre por herencia técnica, pero el color ya es esta paleta, no la
crema/rojo-ladrillo original. Las capturas reales del producto
(`bunkai-login-hero.png`, `bunkai-login-full.png`) no se recolorean — son
la UI real de la app, fuera del alcance de "nuestra" marca.

## Decks (formato `html-ppt`, local)

Serie escalonada, no un deck por skill de una sola tirada. Sirven de fuente
para recortar después contenido hacia GitHub, sitio personal y LinkedIn —
no son el destino final. Guardados a nivel local (no publicados como
Artifact). `presentaciones/assets/` es compartido por todos los decks
(fonts, temas, `runtime.js`, imágenes); cada deck vive en su propia carpeta
dentro de `presentaciones/` y referencia los assets como `../assets/...`.

### Bases visuales — 3 probadas, 2 vigentes

Se compararon 3 temas sobre el mismo contenido (bosquejo panorámico,
descartado tras la decisión — ver `CHANGELOG.md`):

| Tema | Estado | Archivo CSS | Rasgo distintivo |
|---|---|---|---|
| A — original | **descartado** (muy plano) | `assets/knowledge-arch-blueprint.css` | fondo blanco liso, sin variación |
| B — contraste | **vigente** | `assets/knowledge-arch-blueprint-contrast.css` | mismas clases `kb-*`; tono por slide (`.tone-dark/.tone-mid/.tone-light`) en vez de un solo color |
| C — híbrido | **vigente** | `assets/bunkai-brand.css` | arquitectura genérica (`base.css`) + componentes nuevos (mapa de workflow, terminal, step-cards, `gradient-text`) + fondo animado de constelación (`fx-host[data-fx="constellation"]`), tono por slide igual que B |

Las 2 vigentes quedan asignadas por canal (decidido 2026-09-19), no compiten
entre sí:

| Tema | Canal | Por qué |
|---|---|---|
| B — contraste | LinkedIn | lectura rápida, alto contraste, funciona en carrusel y en miniatura |
| C — híbrido | sitio personal (`cescolqa.github.io`) | más interactivo, soporta profundidad y recorrido |

No hay un tema único para toda la serie: hay un tema por destino.

**Dos tipos de deck:**

- **Onboarding/contexto** (uno solo, general, no específico de skill): la
  idea, los 4 pilares, invitación a seguir la serie. Se publica primero.
  Único deck con la imagen completa del producto como portada.
- **Por skill** (`project-discovery`, `shift-left-testing`,
  `sprint-testing`): se publican después, escalonados. Cada uno con
  portada tipográfica propia (nombre de la skill) + el logo chico
  (`bunkai-mark-flat.png`) como ancla de marca — nunca la imagen completa,
  para que la serie no se vea repetida publicación tras publicación.

| Deck | Archivo | Slides | Pilar destacado | Pilar 4 |
|---|---|---|---|---|
| Onboarding/contexto (tema A, descartado) | `presentaciones/onboarding-contexto/onboarding-contexto.html` | 9 | los 4, panorama | n/a — es el panorama |
| Onboarding/contexto (tema B, contraste) | `presentaciones/onboarding-contexto/onboarding-contexto-b-contraste.html` | 9 | los 4, panorama | n/a — es el panorama |
| Onboarding/contexto (tema C, híbrido) | `presentaciones/onboarding-contexto/onboarding-contexto-c-hibrido.html` | 9 | los 4, panorama | n/a — es el panorama |
| `project-discovery` | `presentaciones/project-discovery/project-discovery.html` | 11 | Pilar 2 · Rol + IA asistida | sí — slide de reflexión |
| `shift-left-testing` | — pendiente | — | Pilar 1 · Rol analista (candidato) | sí, cuando se arme |
| `sprint-testing` | — pendiente | — | Pilar 3 · Agentes orquestados (candidato) | sí, cuando se arme |

`project-discovery` todavía corre sobre el tema A (`knowledge-arch-blueprint.css`)
— migrar a B o C queda pendiente de qué tema se fije como definitivo.

**Regla de pilar por deck**: cada deck de skill destaca UN pilar entre 1-3
(elección estratégica, no forzada) MÁS el pilar 4 siempre presente como
capa personal. El onboarding es el único que presenta los 4 juntos, como
panorama.

## Reglas generales de formato

Aplican a todo deck nuevo (checklist antes de dar por terminado un deck):

- Paleta de marca fija (tabla arriba) — nunca crema/rojo-ladrillo.
- Portada siempre visual/contundente: imagen hero en el deck de onboarding,
  tipografía protagonista + logo chico en los decks de skill. Nunca
  cargada de texto, nunca adelanta el próximo deck (eso va en el cierre).
- Nunca numeración de serie en pantalla ("deck 2 de la serie", "Deck 3 ·")
  — esa secuencia va en el texto de publicación, no en la slide. El puente
  al siguiente tema se hace por contenido, no por ordinal.
- Sin promesas de canal prematuras (GitHub/Sitio/LinkedIn) hardcodeadas en
  el cierre — eso también va en el texto de publicación.
- Cierre con llamado a la acción real ("Sigue la serie"), nunca una fecha
  puntual ("la semana que viene") ni una frase pasiva.
- Tono profesional incluso en contenido personal/testimonial (Pilar 4) —
  sin frases casuales.
- Castellano neutro, sin voseo ni modismos regionales de ningún país.
- Los 4 pilares están cerrados; la lista de skills NO — no frasear "3
  skills" como si fuera un total fijo. No numerar tarjetas de skills
  ("01/02/03") como si implicaran un orden cerrado.
- Todo slide se audita contra overlap: el formato es pantalla fija sin
  scroll, contenido apilado puede pisar el footer si no se controla el alto.
- Sacar slides que sirven a la estrategia de publicación de César, no al
  valor para quien lee.

## Relación con la comparación de niveles (`niveles/` en cada práctica)

Cuando se corran otras combinaciones del dial sobre BK-859
(`niveles/profundidad-senior_registro-senior/`, etc.), sirven de insumo
para decidir qué tan técnico o qué tan llano conviene el mensaje en cada
canal — no se decide a ciegas, se compara.

## Estado

`en curso` — estructura, contenido y paleta de marca (tabla arriba) son la
**base aprobada** para los 9/11 slides de contenido. A nivel visual, se
cerró una ronda de exploración (2026-09-17): 3 temas comparados sobre el
mismo contenido, **A descartado** (plano), **B y C vigentes** en paralelo
(ver tabla "Bases visuales" arriba). Nota abierta: la URL de las capturas
de producto es de **staging** — confirmar antes de publicar afuera si
conviene esperar una de producción.

El contenido de toda pieza deriva de `fundamento.md`. Este documento define
únicamente la forma.

Próximo paso: reescribir el deck `project-discovery` contra `fundamento.md`
(regla de sujeto + balance del inventario) antes de construir
`shift-left-testing` (deck 3, Pilar 1 · Rol analista candidato).
No reabrir las decisiones de contenido/estructura ya cerradas (ver
`CHANGELOG.md` si hace falta recordar por qué se descartó algo).
