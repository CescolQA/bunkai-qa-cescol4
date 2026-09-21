# Guiones — deck `onboarding-tecnico`

> **DECISIÓN (2026-09-21): guion A, con dos ajustes.** Versión final en
> `guion-definitivo.html`. Los tres guiones de abajo quedan como registro de los
> ángulos evaluados; no se editan.
>
> | Ajuste | Qué cambió |
> |---|---|
> | Slide 5 | sale "Tres clientes, una fuente". El repositorio admite tres clientes de IA, pero el trabajo real se hace desde uno: presentarlo como capacidad propia infla lo hecho. En su lugar entra el contexto del modelo, apoyado en un documento propio |
> | Slide 6 | absorbe el arreglo de configuración entre clientes, contado como corrección y no como forma de trabajo |
> | Vocabulario | sale la palabra "instrumental" de todo el deck. Se dice herramientas o entorno |
> | Guion B | descartado |
>
> Queda abierto: los toques del guion C que César dijo que iba a evaluar.

> Pieza nueva, autónoma. No depende de ningún otro deck ni anuncia ninguno.
>
> Recorte: **el entorno que hubo que montar, entender y reparar antes de poder
> practicar el rol.** Lo que pasa después del montaje (leer el producto, refinar,
> probar) es materia del deck `onboarding-contexto` y de los decks por skill.

## Por qué es una pieza aparte

Le habla a un lector distinto. El deck de contexto responde "qué sabe hacer esta
persona con un producto"; este responde "¿puede operar y reparar el instrumental
con el que lo hace?". Son dos competencias que se evalúan por separado, y la
segunda no se puede simular.

## Decisiones declaradas antes de escribir

| Decisión | Por qué |
|---|---|
| El boilerplate no se presenta como propio | `fundamento.md` §4. El punto de partida es un boilerplate agéntico de equipo. Lo propio es la adaptación, la conexión del instrumental y las correcciones. Decirlo con precisión es lo que vuelve creíble el resto |
| Las herramientas se nombran por lo que resuelven, no por su marca | `fundamento.md` §2. El lector primario no conoce los nombres. "Un conector de documentación oficial" comunica; una lista de marcas no |
| Los tres arreglos son el pico de la pieza | son la evidencia que ninguna otra pieza tiene: no se puede reclamar sin commit |
| Nada de catálogo de herramientas | una enumeración sin decisión detrás incumple `fundamento.md` §4, columna "No" |
| El "modo de operar" entra como el porqué, no como slide propia | no tiene fila de evidencia en §5. Sostiene decisiones, no se afirma solo |
| Portada tipográfica + logo chico | `README.md`. La imagen completa del producto es exclusiva del deck de onboarding de contexto |
| Ningún cierre anuncia otra pieza | `fundamento.md` §6 |

## Evidencia disponible (`fundamento.md` §5.7)

Incorporada al inventario el 2026-09-21 como **§5.7 · Montaje y reparación del
entorno**. Va al final de §5 y no en su lugar cronológico para no renumerar las
subsecciones y romper las citas de los guiones ya cerrados. Estas son las filas
que la pieza usa, todas verificables en el historial del repositorio.

| Eje | Qué hubo | Prueba |
|---|---|---|
| Dirigido a mano | entorno montado desde un boilerplate agéntico: repositorio propio, adaptación inicial y faltantes de instalación resueltos | `c854bf2`, `ce834ba`, `3577c43` |
| Dirigido a mano | seis conectores externos declarados y autenticados: documentación oficial, búsqueda web, navegador, base de datos, esquema de API, colecciones de API | `.mcp.json` |
| Dirigido a mano | catálogos de la instancia de incidencias cargados: campos y flujos de trabajo reales, no valores de ejemplo | `.agents/jira-fields.json`, `.agents/jira-workflows.json` |
| Dirigido a mano | tres clientes de IA distintos operando el mismo repositorio contra una sola fuente de instrucciones | `.claude/`, `.opencode/`, `.codex/` |
| Dirigido a mano | corrección de configuración: dirección de API de staging con valor de ejemplo todavía vivo | `7d058ff` |
| Dirigido a mano | corrección de configuración: nombres de conectores que no coincidían con la configuración real | `8b41ceb`, `3e43af9` |
| Dirigido a mano | corrección de configuración: mismo conector definido distinto en los tres clientes | `b782662` |
| Dirigido a mano | **corrección de código**: el sincronizador de incidencias fallaba cuando la instancia devolvía los tipos traducidos ("Historia" en vez de "Story"). Resuelto matcheando por identificador en lugar de por nombre | `afb37e8` |
| Dirigido a mano | herramienta propia agregada: un comando que compila el estado real del proyecto en el momento, sin caché | `1d69608` |
| Dirigido a mano | migración completa de instancia de incidencias: repuntar la dirección, adoptar los catálogos nuevos, verificar que todo siguiera respondiendo | `2ad69e8`, `86d44c0`, `143dce9` |
| Dirigido a mano | estudio propio de cómo el repositorio despacha agentes y subagentes | `docs/training/subagent-architecture-guide.md` |

## En qué se diferencian

| | A · El montaje | B · El instrumental | C · El montaje con tesis |
|---|---|---|---|
| Orden | cronológico: de la instalación a la primera práctica | argumentativo: una tensión, tres fallas, una conclusión | enmarcado: tensión primero, montaje después |
| Abre con | lo que nadie te entrega andando | la idea de que la herramienta viene sola y funcionando | esa idea, en una slide corta |
| Eje del relato | qué hubo que dejar funcionando | qué falló y quién lo arregló | ambas, en ese orden |
| Lo que deja | "esta persona se monta su propio entorno" | "esta persona puede responder por la herramienta, no solo usarla" | "se lo montó, y además lo repara" |
| Gancho | medio. Crece hacia el bug | alto desde la slide 2 | alto al abrir, sostenido |
| Densidad | baja, una idea por slide | media | alta. Dos slides fusionan dos ideas |
| Riesgo | puede leerse como bitácora de instalación | deja menos visible el alcance del montaje | si se recorta mal, queda cargado |
| Lector que mejor lo recibe | líder de proyecto, reclutador técnico | líder de QA, perfil de ingeniería | ambos |

---

## Guion A · El montaje

9 slides. 9 con el rol como sujeto.

| # | Slide | Qué dice | Sujeto | Eje | Evidencia |
|---|---|---|---|---|---|
| 1 | Portada | tipografía del nombre de la pieza + logo chico. Kicker sobre lo que viene antes de la primera práctica | ancla | n/a | n/a |
| 2 | Lo que nadie te entrega andando | para trabajar así no alcanza con saber QA. Hay que dejar un entorno funcionando primero, y ese entorno no viene armado | rol | criterio previo | §1 |
| 3 | Qué había que dejar listo | terminal, un modelo con plan propio, repositorio versionado y un boilerplate agéntico de equipo como punto de partida. El boilerplate no es mío; la adaptación sí | rol | a mano | `c854bf2`, `ce834ba`, `3577c43` |
| 4 | Conectar el instrumental | seis conectores externos autenticados y verificados uno por uno, más los catálogos reales de la instancia de incidencias en vez de valores de ejemplo | rol | a mano | `.mcp.json`, catálogos |
| 5 | Tres clientes, una sola fuente | el mismo repositorio se opera desde tres clientes de IA distintos, con las instrucciones en un solo archivo. Si se desalinean, no avisa: rompe en silencio | rol | a mano | `.claude/`, `.opencode/`, `.codex/` |
| 6 | Lo primero que se rompió | una dirección de API con el valor de ejemplo todavía vivo, y nombres de conectores que no coincidían con la configuración real. Encontrados y corregidos antes de que contaminaran una prueba | rol | a mano | `7d058ff`, `8b41ceb`, `b782662` |
| 7 | El bug de verdad | el sincronizador de incidencias fallaba porque la instancia devolvía los tipos traducidos. Lo resolví matcheando por identificador: un nombre se traduce, un identificador no | rol | a mano | `afb37e8` |
| 8 | Mudanza de instancia | migrar el proyecto a otra instancia: repuntar la dirección, adoptar catálogos nuevos y verificar que cada pieza siguiera respondiendo | rol | a mano | `2ad69e8`, `86d44c0`, `143dce9` |
| 9 | Cierre | recién con esto andando empieza el trabajo del rol. Quien no monta su entorno depende de que alguien se lo mantenga | rol | posicionamiento | §1 |

---

## Guion B · El instrumental

9 slides. 9 con el rol como sujeto.

| # | Slide | Qué dice | Sujeto | Eje | Evidencia |
|---|---|---|---|---|---|
| 1 | Portada | tipografía + logo chico. Kicker sobre la herramienta que también falla | ancla | n/a | n/a |
| 2 | La creencia cómoda | se habla de usar IA como si la herramienta viniera sola, armada y sin errores. En la práctica hay que montarla, configurarla y repararla | rol, tesis | posicionamiento | §5.1 |
| 3 | Mi posición | no delego criterio en un instrumental que no entiendo. Por eso lo primero fue montarlo yo, no recibirlo hecho | rol | posicionamiento | §1 |
| 4 | Lo que monté | terminal, modelo con plan propio, repositorio versionado, boilerplate agéntico adaptado, seis conectores autenticados y los catálogos reales de la instancia de incidencias | rol | a mano | `c854bf2`, `.mcp.json`, catálogos |
| 5 | Falla 1 · configuración de ejemplo | direcciones y nombres que habían quedado con el valor de plantilla. Si no se detectan, una prueba corre contra el lugar equivocado y el resultado parece válido | rol | a mano | `7d058ff`, `8b41ceb`, `3e43af9` |
| 6 | Falla 2 · desalineación silenciosa | el mismo conector definido distinto en los tres clientes del repositorio. No da error: da comportamientos distintos según desde dónde se trabaje | rol | a mano | `b782662` |
| 7 | Falla 3 · un bug de código | el sincronizador de incidencias fallaba cuando la instancia devolvía los tipos traducidos. Lo corregí matcheando por identificador en vez de por nombre | rol | a mano | `afb37e8` |
| 8 | Lo que le agregué | un comando propio que compila el estado real del proyecto en el momento, sin caché: variables, conectores, credenciales, estado del repositorio | rol | a mano | `1d69608` |
| 9 | Cierre | quien puede reparar el instrumental es quien puede confiar en lo que el instrumental produce | rol | posicionamiento | §1 · §5.1 |

---

## Guion C · El montaje con tesis

9 slides. 9 con el rol como sujeto. Toma de B la apertura y el cierre, de A el
recorrido del montaje, y fusiona dos pares de slides para entrar en la misma
extensión.

| # | Slide | Qué dice | Sujeto | Eje | Evidencia |
|---|---|---|---|---|---|
| 1 | Portada | tipografía + logo chico. Kicker sobre la herramienta que también falla | ancla | n/a | n/a |
| 2 | La creencia cómoda | se habla de usar IA como si la herramienta viniera armada y sin errores. Hay que montarla, y falla | rol, tesis | posicionamiento | §5.1 |
| 3 | Lo que nadie te entrega andando | para trabajar así no alcanza con saber QA: terminal, modelo con plan propio, repositorio versionado y un boilerplate agéntico de equipo como punto de partida. El boilerplate no es mío; la adaptación sí | rol | a mano | `c854bf2`, `ce834ba`, `3577c43` |
| 4 | Conectar el instrumental | seis conectores autenticados uno por uno, catálogos reales en vez de valores de ejemplo, y tres clientes de IA operando el mismo repositorio contra una sola fuente de instrucciones | rol | a mano | `.mcp.json`, catálogos, `.claude/` `.opencode/` `.codex/` |
| 5 | Lo primero que se rompió | valores de plantilla todavía vivos y el mismo conector definido distinto en cada cliente. Ninguno da error: dan resultados equivocados que parecen válidos | rol | a mano | `7d058ff`, `8b41ceb`, `b782662` |
| 6 | El bug de verdad | el sincronizador fallaba porque la instancia devolvía los tipos traducidos. Lo corregí matcheando por identificador: un nombre se traduce, un identificador no | rol | a mano | `afb37e8` |
| 7 | Mudanza de instancia | migrar el proyecto a otra instancia: repuntar la dirección, adoptar catálogos nuevos, verificar que cada pieza siguiera respondiendo | rol | a mano | `2ad69e8`, `86d44c0`, `143dce9` |
| 8 | Lo que le agregué | un comando propio que compila el estado real del proyecto en el momento, sin caché | rol | a mano | `1d69608` |
| 9 | Cierre | quien puede reparar el instrumental es quien puede confiar en lo que produce. Por eso el montaje vino antes que la primera práctica | rol | posicionamiento | §1 · §5.1 |

---

## Checklist antes de pasar a HTML

- [ ] Proporción de sujeto: mínimo 2 de cada 3 slides sobre el rol. Los tres guiones declaran 9 de 9.
- [ ] Cada slide de contenido cita un commit o un archivo verificable.
- [ ] El boilerplate de equipo aparece como punto de partida, nunca como obra propia.
- [ ] Ninguna slide es un catálogo de herramientas sin decisión detrás.
- [ ] Las herramientas se nombran por lo que resuelven.
- [ ] Ningún cierre anuncia otra pieza.
- [ ] Búsqueda laboral implícita.
- [ ] Una idea por slide.
- [ ] Castellano neutro, sin voseo.

## Estado

Evidencia incorporada a `fundamento.md` §5.7 el 2026-09-21. La pieza ya cumple
el checklist de §7 sin excepción. Falta la elección de guion para pasar a HTML.
