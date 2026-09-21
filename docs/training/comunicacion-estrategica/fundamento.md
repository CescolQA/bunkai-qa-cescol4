# Fundamento de la comunicación

> Capa base. Define **qué se comunica y por qué**.
> `README.md` define **cómo se ve** (decks, paleta, formato). No se duplican.
> Toda pieza publicada (post de LinkedIn, página del sitio, deck) deriva de este documento.

## Cómo se usa este documento

Es la definición raíz. Ante cualquier duda sobre tono, contenido o enfoque de una
pieza, se vuelve acá antes de seguir iterando.

| Situación | Qué hacer |
|---|---|
| Una pieza no comunica lo que se busca | revisar contra §1, §3 y §7 antes de reescribirla |
| Una idea nueva no encaja en lo definido | probarla como alternativa declarada, no como excepción silenciosa |
| Se itera dos veces sin avanzar | parar y volver acá. La traba suele estar en una definición ausente, no en la redacción |

## 1. Posicionamiento

Una sola frase, la misma en todos los canales:

> Analista funcional y de pruebas que está construyendo un rol híbrido: el criterio
> de análisis y QA que ya tenía, ejecutado ahora con IA agéntica sobre un producto real.

Tres anclas que sostienen esa frase y no pueden faltar en el conjunto de las piezas:

| Ancla | Qué afirma | Por qué importa al lector |
|---|---|---|
| Criterio previo | analista funcional + analista de pruebas, con recorrido propio | no es alguien que empezó ayer |
| Práctica real | producto real, historias reales, defectos reales | no es un curso ni un tutorial |
| Dirección, no botón | saber qué pedir, juzgar lo que vuelve, decidir cuándo profundizar | separa el perfil de quien solo usa un chat |

## 2. Audiencia y conclusión buscada

| Lector | Qué está evaluando | Qué debe concluir |
|---|---|---|
| Reclutador (sin trasfondo QA) | encaje rápido con una búsqueda | perfil actualizado, trabaja con IA de verdad |
| Líder de QA | nivel técnico y criterio | sabe QA de fondo, la IA no le tapa los huecos |
| Líder de proyecto | qué aporta a un equipo | reduce tiempo de arranque y levanta el piso de análisis |
| Par de la industria | si vale seguirlo | tiene algo propio para contar, no repite tendencias |

Lector primario: **quien evalúa perfiles**. Si una pieza no le dice nada a ese lector, no se publica.

## 3. Regla de sujeto

Regla central, y la que faltaba:

> **El sujeto de toda pieza es César. El producto, la skill y la herramienta son el escenario.**

Test de una unidad (slide, párrafo, sección): *¿de quién habla?*

| Sujeto | Uso permitido |
|---|---|
| César: decisión, criterio, aprendizaje, cambio de método | libre, es el material principal |
| Producto ajeno (Bunkai TMS) | solo como escenario o prueba de una afirmación propia |
| Skill o herramienta | solo como medio, nunca como protagonista |

Proporción mínima: **2 de cada 3 unidades hablan del rol o del criterio propio**.
Un hallazgo técnico sobre el producto solo entra si la pieza explica qué decisión
propia lo produjo y qué cambió a partir de él.

Contraejemplo registrado: el primer deck de `project-discovery` tenía 7 de 11 slides
con el producto como sujeto. El deck de onboarding, que sí gustó, tenía 6 de 9 con el
rol como sujeto. La diferencia entre "gustó" y "no gustó" fue exactamente esa.

Corrección del 2026-09-21: la cifra del deck de onboarding figuraba acá como 8 de 9.
El recuento slide por slide da 6 de 9, apenas por encima del mínimo, y tres slides
fallan de lleno (una ficha de producto y dos anuncios de la pieza siguiente). La regla
se sostiene igual; el dato que la ilustraba estaba inflado.

## 4. Qué se comunica y qué no

| Sí | No |
|---|---|
| lo efectivamente hecho, con prueba | proyectar como logrado lo que está en curso |
| el criterio aplicado y por qué | enumerar herramientas sin decir qué se hizo con ellas |
| lo que no funcionó y qué se aprendió | vender la IA como atajo |
| la serie en curso, con continuidad | fechas prometidas de publicación |
| el nivel real de cada etapa | jerga sin definir para el lector no técnico |

**Búsqueda laboral: implícita.** Nunca se declara disponibilidad. El contenido demuestra
el perfil y la conclusión la saca el lector. Sin "abierto a oportunidades", sin llamados
a contratar, sin tono de candidatura.

## 5. Inventario de evidencia

La fuente de la que se recorta. Nada se publica sin fila acá.

> **Orden de lectura.** Las subsecciones están numeradas por antigüedad de
> registro, no por cronología del trabajo. La primera etapa real es §5.7, el
> montaje del entorno: es anterior a todo lo demás. Se agregó al final para no
> renumerar y romper las citas de los guiones ya cerrados.

### 5.1 Regla de balance

Se comunican **dos ejes, en proporción cercana al 50/50**:

| Eje | Qué es | Qué demuestra |
|---|---|---|
| Lo que corrió la skill | la ejecución del pipeline agéntico tal como está diseñado | que sé operar el instrumental nuevo |
| Lo que dirigí a mano | lo que pedí, sellé, comparé o hice sin IA porque el proceso lo necesitaba | que tengo criterio propio para auditar lo que la IA produce |

El segundo eje es el que sostiene el diferencial del perfil. Hoy las empresas
están instalando IA y el problema abierto no es generar salida, es **garantizar
que esa salida sea correcta**. Eso lo garantiza alguien con oficio previo: que
sabe qué pedir, que revisa lo que vuelve, y que puede hacer una porción del
trabajo a mano cuando hace falta contrastar. Comunicar solo el primer eje
convierte el perfil en operador de herramienta. Comunicar los dos lo convierte
en quien puede responder por el resultado.

### 5.2 `project-discovery` sobre Bunkai TMS

| Eje | Qué hubo | Prueba |
|---|---|---|
| Skill | 4 fases corridas sobre un repositorio desconocido (2026-08-17): PRD, SRS, glosario de dominio, 20+ subdominios mapeados | commit `1f8ce57`, artefactos en `.context/` |
| Dirigido a mano | decisión de extender la fase 3 en vez de cerrarla con "None" ante la ausencia total de CI/CD; marcado explícito de `Unknown` en lo que no tenía respaldo | assessment en `AGENTS.md` |
| Dirigido a mano | mapa propio de capas e integraciones del sistema (UI / API / RPC / DB / RLS / agéntica) con glosario en lenguaje llano, pedido como lente de lectura para las prácticas siguientes | `docs/training/bunkai-capas-e-integraciones-para-qa.md` |
| Dirigido a mano | guía de estudio sobre cómo el repositorio despacha agentes y subagentes | `docs/training/subagent-architecture-guide.md` |

### 5.3 `shift-left-testing` sobre BK-509

Práctica diseñada en 3 fases contra una historia ya resuelta en producción, para
tener respuesta correcta con la que contrastar.

| Eje | Qué hubo | Prueba |
|---|---|---|
| A mano, sin IA | análisis ciego completo de la historia: ambigüedades, gaps, riesgo y preguntas, hecho antes de correr nada | `BK-509.../phase1-blind-analysis.md` |
| A mano, sin IA | formulario local de pasada ciega, autoguardado y exportable, para que el ejercicio quedara sellado | archivo HTML de la práctica |
| Skill | refinamiento asistido completo, con el Preflight Gate bloqueando el arranque hasta tener contexto suficiente | `shift-left-refinement.md` en el cache de PBI |
| Dirigido a mano | brief de contexto acotado a la historia, creado para que humano e IA arrancaran del mismo material y la comparación fuera legítima | `business-context-brief.md` |
| Dirigido a mano | mapa de contexto de negocio verificado contra la base de datos de staging | `BK-509.../business-context-map.md` |
| Dirigido a mano | comparación de 3 vías: ciego humano vs asistido por IA vs resolución real de producción | `BK-509.../comparison-fase3.md` |
| Dirigido a mano | checklist transversal de madurez del sistema, nacido de esta práctica y aplicable a cualquier historia futura | `docs/training/shift-left-readiness-checklist.md` |

**Hallazgo destacable**: en la comparación de 3 vías hay un punto que detectó
únicamente el análisis humano y que ni la IA ni el proceso real de producción
señalaron: los criterios de aceptación mezclaban nivel técnico de API con nivel
funcional. Es evidencia concreta, verificable y fechada de que el criterio propio
aporta algo que la herramienta no cubre.

### 5.4 `sprint-testing` sobre BK-859

| Eje | Qué hubo | Prueba |
|---|---|---|
| A mano, sin IA | pasada ciega completa de diseño de casos, sellada en commit antes de abrir el material asistido | `pasada-ciega-completada.md`, commit `7d01f4d` |
| A mano, sin IA | fixtures montados a mano en Postman, sin asistencia, para que la ejecución no dependiera del mismo instrumental | `fixture-b-postman.md` |
| Skill | corrida de `/sprint-testing` con las técnicas formales de diseño aplicadas: particiones, valores límite, transición de estados, tabla de decisión | `pasada-asistida/01` a `05` |
| Skill + dirección | matriz de casos iterada hasta v4 por pedido propio, hasta llegar a un formato reusable por criterio de aceptación | `pasada-asistida/06` a `06d` |
| Dirigido a mano | rampa de arranque: checklist para ubicarse en la historia en los primeros minutos | `rampa-de-arranque.md` |
| Dirigido a mano | modelo de roles, estados y formas de membresía, con primer de fixtures para lector no técnico | `modelo-de-roles-y-membership.md` |
| Dirigido a mano | segunda versión de los hallazgos de reconocimiento reescrita en lenguaje llano, para comparar cuál comunica mejor | `reconocimiento-hallazgos-2-lenguaje-simple.md` |
| Dirigido a mano | comparativa ciega vs asistida, y decisión de cerrar la práctica en el paso 7 por alcance, no por bloqueo | `07-comparativa-ciega-vs-asistida.md` |
| Ejecución real | 7 casos ejecutados con resultado correcto y 2 defectos detectados en la aplicación | `08-ejecucion-fixtures-A-B.md` |

### 5.5 Método propio, transversal

Aplica a todas las prácticas. Es el eje manual en su forma más visible: nadie lo pidió, no lo genera ninguna skill.

| Qué | Prueba |
|---|---|
| Backlog de entrenamiento con iniciativas propias, separando núcleo, método, plantilla y propuestas de equipo | `docs/training/BACKLOG.md` |
| Dial de profundidad y registro: misma práctica reproducible en distintos niveles para comparar cuál comunica mejor | `BK-859.../niveles/` |
| Plantilla de práctica reusable | `docs/training/_TEMPLATE/` |
| Convención de entregable partido en archivos cortos numerados con índice, en vez de un documento largo | estructura de `pasada-asistida/` |

### 5.6 Etapas no iniciadas

Se nombran como próximo paso, nunca como capacidad demostrada.

| Etapa | Estado |
|---|---|
| `test-documentation` | no iniciada |
| `test-automation` | no iniciada |
| `regression-testing` | no iniciada |

### 5.7 Montaje y reparación del entorno

Cronológicamente es lo primero: todo esto es anterior a la primera historia
analizada. Es evidencia de una competencia distinta a la de las demás
subsecciones, y se evalúa por separado: no "qué sabe hacer con un producto",
sino "puede operar y reparar el instrumental con el que lo hace".

**Límite declarado**: el punto de partida es un boilerplate agéntico de equipo.
Nunca se presenta como obra propia. Lo propio es la adaptación al proyecto, la
conexión del instrumental, las correcciones y lo que se le agregó.

| Eje | Qué hubo | Prueba |
|---|---|---|
| Dirigido a mano | entorno montado desde el boilerplate agéntico: repositorio propio, adaptación inicial y faltantes de instalación resueltos | `c854bf2`, `ce834ba`, `3577c43` |
| Dirigido a mano | seis conectores externos declarados y autenticados: documentación oficial, búsqueda web, navegador, base de datos, esquema de API, colecciones de API | `.mcp.json` |
| Dirigido a mano | catálogos de la instancia de incidencias cargados: campos y flujos de trabajo reales del proyecto, no valores de ejemplo | `.agents/jira-fields.json`, `.agents/jira-workflows.json` |
| Dirigido a mano | tres clientes de IA distintos operando el mismo repositorio contra una sola fuente de instrucciones | `.claude/`, `.opencode/`, `.codex/` |
| Dirigido a mano | corrección de configuración: dirección de API de staging con el valor de ejemplo todavía vivo | `7d058ff` |
| Dirigido a mano | corrección de configuración: nombres de conectores que no coincidían con la configuración real | `8b41ceb`, `3e43af9` |
| Dirigido a mano | corrección de configuración: el mismo conector definido distinto en cada uno de los tres clientes | `b782662` |
| Dirigido a mano | **corrección de código**: el sincronizador de incidencias fallaba cuando la instancia devolvía los tipos traducidos ("Historia" en vez de "Story"). Resuelto matcheando por identificador en lugar de por nombre | `afb37e8` |
| Dirigido a mano | herramienta propia agregada al repositorio: un comando que compila el estado real del proyecto en el momento, sin caché | `1d69608` |
| Dirigido a mano | migración completa de instancia de incidencias: repuntar la dirección, adoptar los catálogos nuevos, verificar que cada pieza siguiera respondiendo | `2ad69e8`, `86d44c0`, `143dce9` |
| Dirigido a mano | estudio propio de cómo el repositorio despacha agentes y subagentes | `docs/training/subagent-architecture-guide.md` |

**Hallazgo destacable**: el bug del sincronizador (`afb37e8`) es la única fila
del inventario entero donde el trabajo fue encontrar y corregir un defecto en la
herramienta antes de poder usarla. Para llegar ahí hay que leer el código del
instrumental, no solo operarlo. Es el tipo de evidencia que no se puede
reclamar sin commit.

**Las herramientas se nombran por lo que resuelven, no por su marca.** El lector
primario no conoce los nombres de los conectores, y una enumeración de marcas sin
decisión detrás incumple §4.

## 6. Mensaje por canal

Mismo fundamento, dos formatos distintos. No se copia y pega entre canales.

| | LinkedIn | GitHub Pages (`cescolqa.github.io`) |
|---|---|---|
| Rol | apertura y alcance: trae lectores | profundidad: sostiene lo que el post afirma |
| Lector típico | reclutador, contacto, líder que pasa rápido | quien ya se interesó y quiere ver el detalle |
| Formato | post corto, una idea por publicación, serie escalonada | páginas por tema, navegables, con material de respaldo |
| Nivel técnico | términos definidos al pasar, sin jerga cruda | técnico permitido, con contexto |
| Qué NO va | detalle de implementación, nombres de archivos, rutas | tono de anuncio, texto de venta |
| Relación | cada post apunta al sitio para el detalle | el sitio nunca depende de haber leído el post |

La forma visual de cada canal (tema, paleta, plantilla) se define en `README.md`,
no acá: tema B para LinkedIn, tema C para el sitio.

**Cada pieza es autónoma.** Se entiende sin haber visto ninguna otra, no anuncia
la siguiente y no ocupa un lugar fijo en una secuencia. Una misma skill puede
dar lugar a varias piezas sobre recortes distintos. El orden de publicación, el
hilo entre piezas y la invitación a seguir viven en el texto de publicación, que
se escribe aparte y se puede cambiar sin tocar la pieza.

## 7. Checklist de una pieza publicable

Se aplica antes de dar por terminada cualquier pieza.

- [ ] El sujeto es el rol propio, no el producto ni la herramienta.
- [ ] Cumple la proporción 2 de 3.
- [ ] El conjunto mantiene el balance 50/50 entre lo corrido por la skill y lo dirigido a mano.
- [ ] Cada afirmación tiene fila en el inventario de evidencia.
- [ ] Un reclutador sin trasfondo QA entiende la idea sin traducción.
- [ ] Un líder de QA no encuentra nada inflado ni impreciso.
- [ ] La búsqueda laboral queda implícita.
- [ ] Hay una idea principal, no cinco.
- [ ] Castellano neutro, sin voseo ni modismos regionales.

## 8. Relación con los 4 pilares

Los pilares (ver `README.md`) organizan el material; no son el mensaje.

| Pilar | Función en la comunicación |
|---|---|
| 1 · Rol analista | da credibilidad de base: el criterio no nace con la IA |
| 2 · Rol + IA asistida | es el diferencial actual del perfil |
| 3 · Agentes orquestados | marca dirección: hacia dónde va el aprendizaje |
| 4 · Experiencia y criterio propio | es la voz. Convierte un informe técnico en un testimonio |

Cada pieza de skill destaca un pilar entre 1 y 3, con el pilar 4 siempre presente
como capa personal.

## 9. Reglas de redacción

Salieron de la construcción de los decks `onboarding-tecnico` y
`onboarding-contexto` (2026-09-21). Se aplican al copy de cualquier pieza, en
cualquier canal, y se controlan antes de dar una pieza por cerrada.

### 9.1 Títulos descriptivos, no sentencias

Un título que afirma una creencia fuerte se refuta en la primera lectura, y una
pieza no puede depender de que el lector comparta la premisa. Se enuncia lo
verificable.

| Título descartado | Por qué |
|---|---|
| "Recién acá empieza el trabajo del rol" | configurar, actualizar y adaptar ya es trabajo del rol. El perfil no arranca ahí |
| "Lo que al repositorio le faltaba" | reprocha al equipo. Era una mejora detectada en el uso |
| "La configuración no falla, miente" | registro informal |
| "Lo que nadie entrega andando" | carencia absoluta, y falsa: sí hay repositorio, boilerplate y accesos |
| "No es usar IA, es dirigirla" | premisa discutible, y ya es el cierre de otra pieza |

### 9.2 Sin carencia absoluta ni reproche

Lo que se recibe existe. El trabajo es actualizarlo, completarlo y verificarlo.
Escribirlo como vacío suena a reproche al equipo o a quien entregó, y el registro
de la serie es el de alguien con oficio que describe su trabajo, no el de alguien
que se queja del punto de partida.

### 9.3 Vocabulario

| No se dice | Se dice |
|---|---|
| instrumental | herramientas, entorno |
| montar | poner a punto, configurar, dejar operativo |
| miente | desalineado, no devuelve ningún error |

La lista crece cuando aparece un término que no corresponde al registro. No se
borra ninguno: un término vedado que reaparece indica que la regla se perdió.

### 9.4 Cobertura sin anunciar cantidad

Una slide que enumera no se cierra en un número ("seis conectores", "tres
capas"): el número envejece y empobrece. Se agrupa por lo que resuelve cada
pieza y se nombra toda la superficie. Las categorías técnicas sí se nombran con
su término propio (MCP, CLI, API, base de datos), porque son el tipo de pieza, no
una marca, y son la señal que un lector técnico escanea de un vistazo.

### 9.5 La tesis no se repite entre piezas

Cada pieza cierra con una idea propia. Si dos piezas cierran con la misma tesis,
las dos pierden fuerza y el conjunto se vuelve repetitivo. Cierres vigentes:

| Pieza | Cierre |
|---|---|
| `onboarding-tecnico` | responder por el entorno, no solo por el producto |
| `onboarding-contexto` | cada etapa deja algo que se puede revisar |
| `project-discovery` | alguien tiene que poder responder |

### 9.6 Largo de la pieza

No hay largo fijo. Ocho o nueve slides es el rango que vienen dando las piezas;
nueve nunca fue una regla. Una pieza de entrada prioriza que el lector la absorba
de una pasada: ante la duda entre desarrollar un episodio más o fundir dos, se
funde.

## Estado

`base v1` — establecido 2026-09-19. Reemplaza el trabajo por intuición sobre las piezas.
Antes de tocar contenido de una pieza se revisa este documento, no al revés.

Primera aplicación: el deck `project-discovery` se reconstruyó entero contra esta
base el mismo día. Pasó de 11 slides a 9, de 7 slides con el producto como sujeto
a 8 de 9 con el rol como sujeto, y perdió el cierre que lo ataba a una serie.

Segunda aplicación: el deck `onboarding-contexto`, construido antes que este
documento, fue auditado contra esta base el 2026-09-21 y reescrito el mismo día.
Los tres guiones propuestos viven en
`presentaciones/onboarding-contexto/guion.md`, el guion elegido y ajustado en
`guion-definitivo.html`, y el deck nuevo en `onboarding-recorrido.html` (nombre
provisional). El deck anterior se conserva sin cambios como registro.

Tercera aplicación: la pieza nueva `onboarding-tecnico`, primera construida con
guion antes que HTML de punta a punta, y primera en pasar por dos rondas de
ajuste sobre el guion sin tocar el deck. De esas rondas salió §9.

**base v2** — 2026-09-21. Incorpora §5.7 (montaje y reparación del entorno) y §9
(reglas de redacción). El método queda así: el fundamento define qué se dice, el
guion lo fija slide por slide, el deck lo construye, y toda corrección entra por
el guion, nunca directo sobre el HTML.

Tercera pieza, nueva: `onboarding-tecnico`, sobre el montaje y la reparación del
entorno. Nació ya derivada de esta base, con sus tres guiones en
`presentaciones/onboarding-tecnico/guion.md` y su evidencia en §5.7. Es la
primera pieza que obligó a ampliar el inventario en vez de recortar de él.
