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
  — descartado (comprometía fecha, o no invitaba a nada). Se reemplazó por
  el CTA "Sigue la serie". **Ese reemplazo quedó superado el 2026-09-19**:
  ver la sección de esa fecha, más abajo.
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

## 2026-09-19 — la ronda de fundamentos

Sesión que bajó a la capa de contenido. Lo descartado acá no es visual:
es qué dice cada pieza y por qué.

### Método de trabajo

- **Iterar el HTML del deck directamente** — descartado. Dos sesiones
  completas (17 y 18 de septiembre) se perdieron ajustando prosa sobre el
  archivo final sin una definición de base. La causa era un hueco de
  definición, no un problema de redacción. Ahora existe `fundamento.md` y
  ningún deck se escribe sin guion previo.
- **Reencuadrar una slide cambiando el verbo** ("Pude haber X, decidí Y"
  como prefijo sobre el mismo dato técnico) — descartado. Cambia la voz, no
  el sujeto: el dato seguía siendo del producto. Ese patrón fue justamente
  lo que no se percibía como cambio.
- **Dos guiones por deck** — ampliado a **tres** (A, B en tensión con A, y C
  como mezcla deliberada). Con dos opciones la elección queda entre extremos;
  la tercera existe para combinar.

### Contenido del deck `project-discovery`

- **Las slides del `openapi.json` y del candado de trazabilidad en la base
  de datos** — sacadas. Eran hallazgos del producto: probaban que Bunkai TMS
  está bien diseñado, no aportaban nada sobre el criterio propio.
- **Guiones B (La garantía) y C (El recorrido con tesis)** — evaluados y no
  elegidos. Quedan completos en `presentaciones/project-discovery/guion.md`.
  De ellos se tomó el cierre, que era más potente que el de A.
- **"Dos caminos, elegí el lento"** — descartado. Nadie compra lentitud y el
  argumento no se sostiene ante un líder técnico. Reemplazado por "Elegí el
  camino que deja rastro": se nombra lo que la decisión garantiza, no lo que
  cuesta.
- **"Cuando nadie te lo explica" / "sin nadie a quién preguntar"** —
  descartados. Dos problemas: suenan a queja contra el equipo, y debilitan el
  mérito, porque sin alternativa no hay criterio sino necesidad. Ahora el
  contexto se cuenta con sus causas reales (traspaso corto, documento viejo,
  equipo ocupado) y en una línea, no en un párrafo.
- **Camino A de encuadre** (slide propia dedicada al marco, deck de 10
  slides) — evaluado y no elegido, ver `encuadre-opciones.html`. Se eligió el
  camino B: la portada y la slide 2 absorben el encuadre y el deck se mantiene
  en 9.

### Reglas que se cayeron

- **"Pilar 4 no rota como titular de un deck"** — descartada el 2026-09-18.
  Estaba escrita en `README.md` desde el commit `cfa62195` pero nunca había
  sido una decisión discutida con César.
- **Cierre con el CTA "Sigue la serie"** — descartado. Ataba cada pieza a un
  orden de publicación y caducaba si ese orden cambiaba. Ahora cada pieza
  cierra con su propia idea y el hilo vive en el texto de publicación. Única
  excepción: el deck de onboarding, cuyo tema es el conjunto.
- **Relación 1 deck por skill** — descartada. Una skill puede dar lugar a
  varias piezas sobre recortes distintos, publicables en cualquier orden.
- **Nombrar los pilares en pantalla** — descartado. Son organizador interno
  para elegir qué contar y auditar el balance; el lector externo no conoce la
  numeración y el contenido tiene que sostenerse sin ella.
- **Tres canales destino** (GitHub, sitio, LinkedIn) — reducido a dos:
  LinkedIn y el sitio personal. GitHub sale de la lista de canales de
  comunicación.
- **Elegir un tema visual único para toda la serie** — descartado. La
  pregunta estaba mal planteada: no había que elegir entre B y C, había que
  asignar cada uno a su canal.

## Copy y títulos (2026-09-21)

- **Kicker de portada "La herramienta también falla"** (guion C de
  `onboarding-tecnico`) — descartado. Abre una serie con tensión en lugar de
  ubicación, y la serie recién arranca. Queda "Antes de la primera práctica".
- **Slide 2 del guion C, la creencia cómoda de que la herramienta viene
  armada** — descartada por el mismo motivo que la versión propia que decía
  "Lo que nadie entrega andando": afirma una carencia que no es real y suena a
  reproche al equipo.
- **"Recién acá empieza el trabajo del rol"** — descartado como cierre del deck
  técnico. Configurar y adaptar ya es trabajo del rol; el título se refuta solo.
- **"Lo que al repositorio le faltaba"** — descartado. Reprocha al equipo cuando
  lo que hubo fue una mejora detectada en el uso y aportada.
- **"La configuración no falla, miente"** — descartado por registro informal,
  misma categoría que "montar".
- **"Seis conectores, uno por uno"** y su reemplazo **"Tres capas de
  conexión"** — los dos descartados. El primero empobrecía la superficie real
  del repositorio, el segundo la cerraba en un número. Quedó el agrupamiento por
  tipo de pieza, con las categorías nombradas (MCP, CLI, API, base de datos).
- **"No es usar IA, es dirigirla"** como cierre de `onboarding-contexto` —
  descartado: es una premisa discutible y además ya cierra la pieza de
  `project-discovery`.

## Estructura de deck (2026-09-21)

- **Tres slides seguidas de episodios técnicos** en `onboarding-tecnico` (valores
  de plantilla, bug del sincronizador, migración de instancia) — descartado.
  Convertía una pieza de entrada en bitácora. Quedaron dos: una que reúne las
  reparaciones en una línea cada una, y otra sobre lo que se le agregó al
  repositorio.
- **Slide de criterio propio como novena** — propuesta y descartada por César:
  el pedido era reestructurar las tres existentes, no sumar una nueva.
- **Nueve slides como largo fijo** — descartado. Era la coincidencia de las dos
  primeras piezas, no una regla. El deck técnico y el de contexto quedaron en 8.
- **Slide propia para el producto** en `onboarding-contexto` — descartada. El
  sujeto es el rol; Bunkai TMS se define en una línea dentro de la slide donde
  se cuenta qué se eligió entrenar.
- **Slide que enumera los 4 pilares** — descartada. Organizan el material, no
  son el mensaje, y obligaban al lector a aprender un esquema interno antes de
  entender la idea.
