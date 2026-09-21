# Comunicación estratégica del entrenamiento

> **Nivel de referencia (dial I-7):** `profundidad semi-senior · registro semi-senior` (default).
> Historial de decisiones descartadas → `CHANGELOG.md`. Este documento describe la base actual, no cómo se llegó a ella.

## Objetivo

Convertir lo entrenado en este repo en una narrativa comunicable hacia afuera
(LinkedIn y el sitio personal) sin perder rigor técnico ni inflar lo hecho.
El qué y el porqué de cada pieza viven en `fundamento.md`; este documento
define la forma.

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
   como testimonio. Presente en toda pieza como capa personal. Puede ser el
   pilar protagonista de una pieza: la regla anterior que se lo prohibía fue
   descartada el 2026-09-18 (nunca había sido una decisión discutida).

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
| `presentaciones/<deck>/guion.md` | bitácora de decisiones + los tres ángulos evaluados |
| `presentaciones/<deck>/comparador-guiones.html` | los tres guiones alineados slide por slide, con el copy real. Es el documento que se lee para elegir |
| `presentaciones/<deck>/guion-definitivo.html` | el guion cerrado, con control contra el fundamento |
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

Los archivos de tema en `presentaciones/assets/` mantienen el nombre
`knowledge-arch-blueprint` por herencia técnica, pero el color ya es esta
paleta, no la crema/rojo-ladrillo original. Las capturas reales del producto
(`bunkai-login-hero.png`, `bunkai-login-full.png`) no se recolorean — son
la UI real de la app, fuera del alcance de "nuestra" marca.

## Decks (formato `html-ppt`, local)

Piezas independientes, publicadas de forma escalonada. **La relación con las
skills no es 1 a 1**: una skill puede dar lugar a una pieza o a varias, cada una
sobre un recorte distinto, y pueden publicarse en cualquier orden. Sirven de fuente
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

**Tres tipos de deck:**

- **Onboarding/contexto**: la idea general y el recorrido completo. Es la única
  pieza cuyo tema ES el conjunto. Único deck con la imagen completa del producto
  como portada. **En reescritura** (2026-09-21): el deck vigente se construyó
  antes de `fundamento.md` y no pasó por la regla de sujeto. Guion A elegido,
  ajustes sin aplicar. El deck viejo se conserva sin cambios como registro.
- **Onboarding/técnico**: el entorno que hubo que montar, entender y reparar
  antes de poder practicar el rol. Pieza aparte porque le habla a otro lector:
  no "qué sabe hacer con un producto", sino "puede operar y reparar las
  herramientas con las que lo hace". Portada tipográfica + logo chico, como los
  decks de skill.
- **Por skill**: portada tipográfica propia (nombre de la skill) + el logo
  chico (`bunkai-mark-flat.png`) como ancla de marca, nunca la imagen
  completa, para que las publicaciones no se vean repetidas entre sí. Cada
  una se sostiene sola y se publica en el orden que convenga.

| Deck | Archivo | Slides | Estado |
|---|---|---|---|
| `project-discovery` | `presentaciones/project-discovery/project-discovery.html` | 9 | terminado (2026-09-19), tema B |
| Onboarding/técnico | — pendiente | 9 | guion A cerrado en `presentaciones/onboarding-tecnico/guion-definitivo.html`. Falta el HTML, tema B |
| Onboarding/contexto (versión anterior, tema A) | `presentaciones/onboarding-contexto/onboarding-contexto.html` | 9 | registro. Anterior al fundamento, no se toca |
| Onboarding/contexto (versión anterior, tema B) | `presentaciones/onboarding-contexto/onboarding-contexto-b-contraste.html` | 9 | registro |
| Onboarding/contexto (versión anterior, tema C) | `presentaciones/onboarding-contexto/onboarding-contexto-c-hibrido.html` | 9 | registro |
| Onboarding/contexto (reescritura) | — pendiente | 9 | guion A elegido, ajustes sin aplicar. Nombre por recorte, no ordinal |
| `shift-left-testing` | — pendiente | — | tres guiones desde el arranque |
| `sprint-testing` | — pendiente | — | tres guiones desde el arranque |

`project-discovery` corre sobre el tema B (`knowledge-arch-blueprint-contrast.css`),
que es el tema de LinkedIn. Reconstruido el 2026-09-19 desde `guion-definitivo.html`.

La columna de pilares salió de esta tabla: se declaran en el guion de cada deck,
no acá (ver la regla más abajo).

**Una skill puede tener varias piezas.** La tabla de arriba lista lo construido,
no un cupo. Un segundo deck sobre `project-discovery`, o tres piezas cortas sobre
`shift-left-testing`, son igual de válidos: cada uno recorta un tema propio y se
sostiene solo. El nombre del archivo lleva el recorte, no un ordinal
(`project-discovery-evidencia.html`, no `project-discovery-2.html`).

**Regla de pilar por deck**: cada deck de skill destaca UN pilar entre 1-3
(elección estratégica, no forzada) MÁS el pilar 4 siempre presente como
capa personal. El onboarding es el único que presenta los 4 juntos, como
panorama.

**Los pilares no se nombran en pantalla** (decidido 2026-09-19). Son un
organizador interno: sirven para elegir qué contar y para auditar el balance
de una pieza, no para etiquetar slides. Un lector externo no conoce la
numeración y no la necesita: el contenido tiene que sostenerse sin ella. El
guion declara qué pilar trabaja cada slide; la slide no lo dice.

## Guion antes del HTML (obligatorio)

Ningún deck se escribe directo en HTML. Primero se redactan **tres guiones** en
`presentaciones/<deck>/guion.md`, los tres derivados de `fundamento.md`. Cada uno
declara, slide por slide: qué dice, quién es el sujeto, qué eje del inventario
usa y qué fila de `fundamento.md` §5 lo respalda.

Los tres ángulos son fijos:

| Guion | Ángulo |
|---|---|
| A | una idea estructurante (por ejemplo, el método de trabajo) |
| B | una idea distinta y en tensión con A (por ejemplo, la garantía de resultado) |
| C | la mezcla: toma de A y de B lo que mejor funciona de cada uno |

C no es un promedio ni una tercera versión suave. Es una combinación deliberada,
y declara en la tabla de diferencias qué tomó de cada lado.

César elige uno. Recién entonces se construye el HTML.

| Etapa | Entregable |
|---|---|
| 1 | tres guiones comparados en una tabla de diferencias |
| 2 | elección |
| 3 | `guion-definitivo.html`: el guion elegido, slide por slide, con badges de ajuste, notas de decisión y tabla de control contra `fundamento.md` |
| 4 | HTML del deck, construido desde ese guion |

Los guiones descartados quedan en el archivo como registro de los ángulos alternativos.

**Toda corrección entra por el guion, nunca directo sobre el deck.** El
`guion-definitivo.html` es el documento de trabajo mientras la pieza se ajusta:
ahí van los cambios de copy, el motivo de cada uno y las decisiones cerradas. El
deck se reconstruye cuando el guion se da por bueno. Escribir la corrección en el
HTML pierde el porqué, y el porqué es lo que evita repetir el camino.

## Reglas generales de formato

Aplican a todo deck nuevo (checklist antes de dar por terminado un deck):

- Paleta de marca fija (tabla arriba) — nunca crema/rojo-ladrillo.
- Portada siempre visual/contundente: imagen hero en el deck de onboarding,
  tipografía protagonista + logo chico en los decks de skill. Nunca cargada
  de texto, nunca adelanta otra pieza.
- Nunca numeración de serie en pantalla ("deck 2 de la serie", "Deck 3 ·")
  — esa secuencia va en el texto de publicación, no en la slide. El puente
  al siguiente tema se hace por contenido, no por ordinal.
- Sin promesas de canal prematuras (GitHub/Sitio/LinkedIn) hardcodeadas en
  el cierre — eso también va en el texto de publicación.
- **Cada pieza cierra con su propia idea**, nunca con el anuncio de la próxima
  entrega. La secuencia, el "seguí la serie" y cualquier invitación viven en el
  texto de publicación, que se escribe aparte y se puede cambiar sin tocar el
  deck. Un cierre que promete la entrega siguiente ata la pieza a un orden y
  caduca si ese orden cambia. Nunca una fecha puntual ni una frase pasiva.
  Excepción única: el deck de onboarding, cuyo tema ES el conjunto.
- **Cada pieza se entiende sola.** Ninguna depende de haber visto otra. Se puede
  publicar en cualquier orden, repetir un tema, o mostrar una sola sin contexto
  previo. Referenciar otra pieza es opcional y se hace por contenido, nunca
  como requisito de lectura.
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
- **Largo no fijo.** Ocho o nueve slides es el rango real; nueve nunca fue
  regla. Ante la duda entre sumar un episodio o fundir dos, se funde
  (`fundamento.md` §9.6).
- **Encuadre verificado, no estimado.** Antes de dar un deck por terminado se
  mide cada slide en el navegador a 1440x810 y se comprueba que el contenido
  no toque el borde ni el pie. El formato es pantalla fija sin scroll.
- **El nombre del archivo lleva el recorte, no un ordinal.**
  `onboarding-tecnico.html`, no `deck-02.html`.
- Copy sujeto a las reglas de redacción de `fundamento.md` §9: títulos
  descriptivos, sin carencia absoluta, vocabulario controlado, sin anunciar
  cantidades, y una tesis distinta por pieza.

## Relación con la comparación de niveles (`niveles/` en cada práctica)

Cuando se corran otras combinaciones del dial sobre BK-859
(`niveles/profundidad-senior_registro-senior/`, etc.), sirven de insumo
para decidir qué tan técnico o qué tan llano conviene el mensaje en cada
canal — no se decide a ciegas, se compara.

## Estado

`en curso`. Al 2026-09-21 el método está cerrado y probado de punta a punta:
fundamento, tres guiones, guion definitivo, deck, y corrección que siempre
vuelve al guion. Tres decks construidos contra esa base.

| Frente | Estado |
|---|---|
| Capa de contenido | `fundamento.md` base v2, con §5.7 y §9 |
| Canales y temas | LinkedIn con tema B, sitio con tema C |
| Deck `project-discovery` | reconstruido desde su guion, 9 slides |
| Deck `onboarding-tecnico` | construido, 8 slides, dos rondas de ajuste sobre el guion |
| Deck `onboarding-contexto` | reescrito como `onboarding-recorrido.html`, 8 slides. El viejo se conserva como registro |
| Nombre definitivo del deck de contexto | **abierto**: `onboarding-recorrido` es provisional |
| Piezas de canal | ninguna escrita todavía |
| Deck `shift-left-testing` | pendiente, con los tres guiones desde el arranque |

Nota abierta: la URL de las capturas de producto es de **staging**.
Confirmar antes de publicar afuera si conviene esperar una de producción.

No reabrir las decisiones ya cerradas sin leer antes `CHANGELOG.md`: cada
entrada dice por qué se descartó algo.
