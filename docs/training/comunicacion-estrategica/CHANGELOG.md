# Changelog — decisiones de diseño descartadas

Registro de lo que se probó durante la iteración de I-8 y no quedó, para no
repetir el mismo camino. La base actual (lo que sí quedó, y desde donde se
sigue iterando) está documentada en `README.md`.

## Tema visual y color

- **Tema crema + rojo ladrillo** (`#F0EAE0` / `#B5392A`, plantilla
  `knowledge-arch-blueprint` original) — descartado. Reemplazado por la
  paleta de marca real de LinkedIn de César: blanco / navy `#1D0847` /
  lavanda `#9486A9` / gris `#AFB4B3`.
- **Fondo blanco liso en las 9 slides (tema A, ya recoloreado a la paleta
  de marca)** — descartado 2026-09-17 por "muy básico". Se compararon 3
  bases sobre el mismo contenido de `onboarding-contexto`: A (plano),
  B (mismas clases `kb-*`, tono alternado por slide: morado fuerte / claro
  / intermedio, no un solo color), C (arquitectura genérica + componentes
  nuevos + fondo animado). B y C quedaron vigentes en paralelo; A se
  descartó del todo.
- **Fondo mesh-gradient (varios radiales superpuestos) para el tema C** —
  probado y descartado el mismo día ("quedó horrible", palabras de
  César). Se reemplazó por fondo plano sólido + el efecto canvas
  `constellation` (puntos + líneas finas conectándose), portado del deck
  de referencia externo (`agentic-qa-boilerplate/decks/shift-left-testing/how-it-works.es.html`,
  tema `tokyo-night` del mismo skill `html-ppt`) y recoloreado a la
  paleta propia. Primera versión del efecto solo en la portada; se
  extendió a las 9 slides con color/opacidad adaptados al tono de cada
  una (puntos blancos fuerte en morado, puntos morado oscuro discretos en
  claro/intermedio) después de que la primera pasada quedara casi
  invisible sobre fondo claro.
- **Un solo tono de color parejo por deck (todo morado, o todo claro)**
  para B y C — descartado. Both temas alternan tono por slide
  (`.tone-dark/.tone-mid/.tone-light`) siguiendo el mismo ritmo: portada
  oscura → claro → intermedio → claro → intermedio → oscura (núcleo) →
  claro → intermedio → oscura (cierre, espejo de portada).
- **Logo del kanji en negro + naranja** — descartado junto con el tema
  anterior. Recoloreado a navy + lavanda para hacer juego con el título.
- **Logo como captura de pantalla con fondo oscuro propio** (chip con
  degradé) — descartado. Se extrajo el kanji solo (sin fondo), como PNG
  transparente manipulable.

## Portadas

- **Misma imagen completa del producto (login/inicio) como portada de
  TODOS los decks de skill** — descartado. Se veía repetida publicación
  tras publicación en una serie semanal. Ahora: solo el deck de
  onboarding/contexto usa la imagen completa; cada deck de skill tiene
  portada tipográfica propia (el nombre de la skill como protagonista) +
  el logo chico como ancla de marca.
- **Portada del deck de onboarding con kicker "Invitación..." + recuadro
  adelantando el próximo deck** — descartado. Portada final: solo imagen
  hero + título + bajada, sin adelantar contenido de otro deck.
- **Las 4 fases de `project-discovery` comprimidas a una línea de texto en
  la portada** — descartado. Vuelven como slide propia ("Las 4 fases"),
  con las cajas completas.

## Organización de archivos

- **Los 3 `.html` de `onboarding-contexto` (A/B/C) sueltos junto a
  `project-discovery.html` en la raíz de `presentaciones/`** — reordenado
  2026-09-17. Ahora cada presentación tiene su propia carpeta
  (`onboarding-contexto/`, `project-discovery/`), con `assets/` compartido
  un nivel arriba. Los bosquejos de comparación (`sketch-a/b/c-*.html`,
  `comparativa-temas.html`) se borraron una vez cerrada la decisión — ya
  cumplieron su función.

## Estructura y contenido

- **Un solo deck de 18 slides** mezclando el pitch de onboarding con el
  recorrido de la skill — descartado. Se separó en 2 tipos de deck:
  onboarding/contexto (general, una vez) + un deck por skill (corto,
  escalonado).
- **Slide 2 del deck de onboarding duplicando el mensaje de la portada** —
  sacada, quedaba redundante.
- **Slide "cómo lo voy a compartir"** (estrategia de publicación interna:
  cadencia, formato) — sacada. Es información para César, no valor para
  quien lee el post.
- **Numeración "01 / 02 / 03" en las tarjetas de skills** — sacada,
  implicaba un orden/cantidad fija que no es real (la lista de skills
  puede crecer). Reemplazada por la etiqueta neutra "SKILL".
- **Cierre "Sigamos la semana que viene" / "La base ya está documentada"**
  — descartado (comprometía fecha, o no invitaba a nada). Reemplazado por
  el CTA "Sigue la serie", igual en los dos decks.
- **Frase "…a medida que avanzo por el pipeline manual"** — descartada,
  restaba peso al pilar de IA asistida. Reemplazada por "…entre el
  criterio humano y la asistencia de IA".
- **Referencia a "Deck 2"/"Deck 3"/"deck N de la serie" en las slides** —
  sacada de toda superficie visible. Esa numeración va en el texto de
  publicación (ej. copy de LinkedIn), nunca hardcodeada en la imagen.
- **Mención a GitHub/Sitio/LinkedIn en el cierre del deck** — sacada, es
  prematuro comprometer canales ahí; va en el texto de publicación.

## Tono e idioma

- **Voseo rioplatense** ("Seguí la serie") — corregido a tuteo neutro
  ("Sigue la serie"). Ningún deck usa voseo — César es venezolano, vive en
  Argentina, pero pidió explícitamente castellano neutro para toda la
  documentación.
- **Tono casual en contenido personal** ("se lo dije a mí mismo y a mis
  amigos, esto está brutal") — corregido a registro profesional.
- **3 pilares** → pasaron a **4** (se sumó "experiencia, criterio y
  aprendizaje propio").
- **Pilar 1 "Rol manual"** → renombrado **"Rol analista"** (el nombre
  original restaba peso al rol).
