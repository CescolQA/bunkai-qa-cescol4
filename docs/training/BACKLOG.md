# Backlog de aprendizaje QA — iniciativas e ideas

Registro vivo de todo lo que se fue haciendo y lo que queda por hacer en esta práctica
de QA asistida por IA. Distinto del `README.md` de esta carpeta: el README es el índice
de las **prácticas por historia** (BK-509, BK-859, ...); este archivo es el mapa de
**iniciativas transversales e ideas de método**.

Convención:

- **Iniciativa** = línea de trabajo con intención, un "para qué", y un próximo paso concreto. Se va a trabajar.
- **Idea / hilo suelto** = surgió durante la práctica, todavía sin decidir si se convierte en iniciativa.
- **Base ejecutada** = trabajo de infraestructura ya cerrado, se lista como referencia, no se sigue de cerca.

Estados: `hecho` · `activa` · `en curso` · `pendiente` · `bloqueado`.

---

## Núcleo — dominar los skills en contexto

Iniciativa principal. El resto del backlog se ordena alrededor de esta.

**Objetivo:** para cada skill de la parte **manual y previa a la automatización** del
pipeline, poder *comprenderlo* (qué hace, sus fases, su modelo de despacho a
subagentes), *aplicarlo* a una historia real, *hacerlo correr* de punta a punta, y
*comparar* el resultado contra cómo se haría a mano sin asistencia. Todo sabiendo de
qué trata el contexto de negocio, no a ciegas.

### Alcance de estos estudios

En foco ahora: entender cómo se trabaja con la IA agéntica en el tramo manual del
pipeline, hasta el paso previo a la automatización.

| Etapa | Skill | En estos estudios |
|---|---|---|
| 0 | `project-discovery` | sí |
| 0.5 | `shift-left-testing` | sí |
| 1-3 | `sprint-testing` | sí |
| 4 | `test-documentation` | sí (probablemente el último) |
| 5 | `test-automation` | no — muy adelante |
| 6 | `regression-testing` | no — muy adelante |

### La espina — pipeline de 6 etapas

```
project-discovery  (etapa 0: reversa del proyecto, PRD/SRS/glosario, .context/)
      |
shift-left-testing (etapa 0.5: refinar ACs antes del sprint)
      |
sprint-testing     (etapas 1-3: QA manual por ticket, ATP/ATR/bugs)
      |
test-documentation (etapa 4: casos en el TMS + scoring ROI)
      |
======= corte de los estudios actuales =======
      |
test-automation    (etapa 5: Plan -> Code -> Review sobre KATA + Playwright)
      |
regression-testing (etapa 6: suite de regresión en CI, GO / CAUTION / NO-GO)
```

### El método — doble pasada + comparación

Lo que diferencia esta práctica de simplemente correr el skill:

1. **Pasada a mano.** Resolver la historia como analista humano sin asistencia diaria: leer, documentar contexto, diseñar casos. Se sella (no se toca después).
2. **Pasada asistida.** Correr el skill real con la IA.
3. **Comparación.** Qué encontró cada una, qué se le escapó a cada una, dónde la IA aportó y dónde metió ruido.

### Avance por skill

| Skill | Comprender | Aplicar a historia | Correr E2E | Comparar vs. manual |
|---|---|---|---|---|
| `project-discovery` | hecho (fases 1-4) | Bunkai TMS completo | hecho (ago 17) | n/a |
| `shift-left-testing` | hecho | BK-509 | hecho | hecho (comparación 3 vías) |
| `sprint-testing` | parcial | BK-859 (cerrada 2026-09-10) | parcial (pasos 1-7; ejecución 7 PASS + 2 defectos del slice fixtures A+B; fixtures C/D fuera de alcance) | hecho (paso 7) |
| `test-documentation` | pendiente | — | — | — |
| `test-automation` | fuera de alcance | — | — | — |
| `regression-testing` | fuera de alcance | — | — | — |

**Próximo paso:** arrancar `test-documentation` como frontera nueva, y muy
probablemente cierre de estos estudios. La comprensión de `sprint-testing` quedó
parcial (no se corrieron las Stages 2-3 completas); si más adelante hace falta, se
retoma con otra historia, no con BK-859. `test-automation` y `regression-testing`
quedan para mucho más adelante, fuera de esta tanda.

---

## Iniciativas

Líneas de trabajo con intención. Cada una tiene un tema, un estado, y un solo
próximo paso concreto.

### Tablero

| Estado | Iniciativas |
|---|---|
| Activa (convención) | **I-7** dial de profundidad y registro |
| En curso | **I-1** dominar skills en contexto · **I-2** registro por audiencia · **I-8** comunicación estratégica del entrenamiento |
| Pendiente | **I-3** trío de onboarding · **I-4** método de pasada a mano · **I-5** brief como herramienta de equipo |
| Bloqueado | **I-6** skill relevamiento funcional inverso (espera input de diseño) |

Temas: `núcleo` (la práctica misma) · `método` (cómo se trabaja) · `plantilla` (algo
que se vuelve reusable en `_TEMPLATE/`) · `equipo` (candidato a proponer) · `skill propio`.

### Fichas

Cinco campos fijos por ficha: qué es, para qué, dónde nació, estado, próximo paso.

---

**I-1 · Dominar los skills en contexto** &nbsp;`núcleo`

| | |
|---|---|
| Qué es | Comprender + aplicar + correr + comparar cada skill del tramo manual del pipeline. |
| Para qué | Saber trabajar con la IA agéntica en QA, no solo apretar el botón del skill. |
| Dónde nació | Primer skill usado (`shift-left-testing`) sobre BK-509. |
| Estado | `en curso` — ver matriz de avance en **Núcleo**. |
| Próximo paso | Arrancar `test-documentation`. |

---

**I-2 · Adaptación de registro por audiencia** &nbsp;`método`

| | |
|---|---|
| Qué es | Reglas para que la documentación hable a analista funcional junior y analista de pruebas senior a la vez, sin jerga sin definir. |
| Para qué | Que el lector entienda sin traducción, sea cual sea su perfil. |
| Dónde nació | Pedido explícito durante BK-859 (docs de reconocimiento "lenguaje simple", matriz de test-plan v4). |
| Estado | `en curso` — aplicado, falta consolidarlo como convención escrita. |
| Próximo paso | Extraer las reglas a un doc transversal en `docs/training/`. |

---

**I-3 · Trío de onboarding de contexto** &nbsp;`plantilla`

| | |
|---|---|
| Qué es | Tres documentos que nivelan el arranque: brief acotado + `rampa-de-arranque.md` + `modelo-de-roles-y-membership.md`. |
| Para qué | Un humano arranca sin los 4 mapas de negocio que la IA sí lee; el trío cierra esa brecha. |
| Dónde nació | Piloteado en BK-859. |
| Estado | `pendiente`. |
| Próximo paso | Copiar los 3 documentos a `_TEMPLATE/` con placeholders. |

---

**I-4 · Método de pasada a mano** &nbsp;`plantilla`

| | |
|---|---|
| Qué es | Formulario HTML standalone con autoguardado y export (`pasada-ciega.html`) + procedimiento de fixtures a mano en Postman (`fixture-b-postman.md`). |
| Para qué | Hacer la pasada ciega y los fixtures sin la IA, para que la comparación sea legítima. |
| Dónde nació | Piloteado en BK-859. |
| Estado | `pendiente`. |
| Próximo paso | Generalizar el HTML y el procedimiento, moverlos a `_TEMPLATE/`. |

---

**I-5 · Brief de contexto de negocio por historia** &nbsp;`equipo`

| | |
|---|---|
| Qué es | El brief acotado a la historia, hoy herramienta personal, propuesto como paso previo al refinamiento del equipo. |
| Para qué | Que el equipo arranque el refinamiento con contexto ya masticado. |
| Dónde nació | Piloteado en BK-509 y BK-859. |
| Estado | `pendiente`. |
| Próximo paso | Redactar la propuesta corta: qué es, qué cuesta, qué ahorra. |

---

**I-6 · Skill propio — relevamiento funcional inverso** &nbsp;`skill propio`

| | |
|---|---|
| Qué es | Lectura híbrida analista funcional + QA de un requerimiento, en reversa. Archivo local en `Documents\practica-relevamiento-funcional-inverso\`. |
| Para qué | Herramienta personal primero, candidato a proponer al equipo después. |
| Dónde nació | Idea propia, fuera de una historia puntual. |
| Estado | `bloqueado` — Parte 1 (contenido, Caso 2) `LOCKED`; Parte 2 (diseño visual) v3 rechazada sin detalle. |
| Próximo paso | Esperar el input de diseño para desbloquear la Parte 2. |

---

**I-7 · Dial de profundidad y registro** &nbsp;`método`

| | |
|---|---|
| Qué es | Dos perillas con la misma escala de tres niveles (`junior` / `semi-senior` / `senior`) para calibrar cómo la IA trabaja y entrega en este repo. |
| Para qué | Que César pida "más analizado" o "más tranquilo" sin discutir formato cada vez, y que el entregable salga a un nivel que pueda defender ante el equipo como propio. |
| Dónde nació | Conversación del 2026-09-10, practicando cómo pedirle trabajo a la IA agéntica. |
| Estado | `activa` — convención de sesión, aplica a todo el trabajo en este repo, no solo al backlog. |
| Próximo paso | Usarla un tiempo y ajustar nombres o defaults si algo no calza. Converge con la mitad "registro" de **I-2**. |

**Contrato**

| | Perilla A · Profundidad | Perilla B · Registro |
|---|---|---|
| Controla | cuánto analiza y cubre | cómo comunica y documenta |
| Niveles | `junior` / `semi-senior` / `senior` | `junior` / `semi-senior` / `senior` |
| Default | `semi-senior`, fijo | `semi-senior`, fijo |
| Duración de un cambio | persiste hasta nuevo aviso | persiste hasta nuevo aviso |

- Sin indicación: las dos en `semi-senior`.
- `junior` = vistazo rápido / lenguaje llano. `semi-senior` = buen desempeño, varios aspectos, sin extremos / nivel medio defendible. `senior` = exhaustivo, todas las técnicas y bordes, auto-revisión / tecnicismo completo, voz de arquitecto QA.
- Cambio por tarea: "profundidad `senior` solo para esto" vuelve a `semi-senior` al terminar.
- Cambio permanente: "de ahora en más profundidad `junior`" queda fijo.
- Palabra suelta ("a fondo", "tranqui", "muy exhaustivo") aplica a profundidad, solo esa tarea.
- "todo `senior`" o "al 100%" mueve las dos, solo esa tarea.
- Cadencia no es perilla: siempre "leer menos y avanzar más" (respuesta corta por defecto, entregable grande por partes con ok entre cada una; override "dame todo junto").

**Señal de sesión**

La IA avisa que el dial está activo. Muestra esta línea en la primera tarea de fondo
de cada sesión en este repo, y cada vez que el dial cambie (con el estado nuevo):

> `Dial: profundidad semi-senior · registro semi-senior (default). Avancemos.`

Si hay un cambio por tarea, lo refleja: `Dial: profundidad senior (solo esta tarea) · registro semi-senior.`

---

**I-8 · Comunicación estratégica del entrenamiento** &nbsp;`método`

| | |
|---|---|
| Qué es | Convertir los 4 pilares del entrenamiento (rol analista base / rol + IA asistida / ecosistema de agentes orquestados / experiencia y criterio propio) en una narrativa comunicable, con núcleo en el rol híbrido (analista funcional + QA) demostrado a través de `project-discovery`, `shift-left-testing` y `sprint-testing`. |
| Para qué | Comunicar hacia afuera (GitHub, sitio personal, LinkedIn) de forma estratégica y agnóstica, entendible por reclutadores sin trasfondo QA. |
| Dónde nació | Conversación del 2026-09-11, después de cerrar BK-859 y armar `niveles/`. |
| Estado | `en curso` — el 2026-09-19 se bajó a la capa que faltaba: **`comunicacion-estrategica/fundamento.md`** define qué se comunica y por qué (posicionamiento, audiencia, regla de sujeto, inventario de evidencia de doble eje, mensaje por canal, checklist). `README.md` queda solo con la forma. Canales cerrados en dos: LinkedIn (tema B) y sitio personal (tema C). Cada pieza es autónoma, sin anclaje a una serie. Deck `project-discovery` reconstruido: 9 slides, tema B. Decisiones descartadas en `CHANGELOG.md`. |
| Próximo paso | Revisar el deck `onboarding-contexto` contra `fundamento.md` (se construyó antes que la base) y escribir las primeras piezas en `piezas/linkedin/` y `piezas/sitio/`. Después, `shift-left-testing` con los tres guiones desde el arranque. Converge con la comparación de niveles (I-7) como insumo de calibración. |

---

## Ideas / hilos sueltos

Surgieron durante la práctica. Todavía no son iniciativa.

- **Elegir próximas historias a practicar:** el backlog de prácticas por historia (README) está vacío después de BK-859. Definir 2-3 candidatas para `test-documentation` y `test-automation`.
- **Guía nueva a incorporar:** hay una guía que se quiere guardar y listar acá. Pendiente de recibir el contenido.
- **Sitio personal `cescolqa.github.io`:** repo separado, prototipo de diseño a iterar. Fuera del alcance de este repo; ahora es uno de los canales destino de **I-8**.

DEF-1 / DEF-2 de BK-859: cerrados como hallazgos de ejercicio. Quedan comentados en
la historia, sin filear como defects formales. No se avanza más.

---

## Base ejecutada

Infraestructura ya cerrada. Referencia, no se sigue de cerca.

| Ítem | Commit / fecha |
|---|---|
| Instalación inicial del boilerplate + faltantes | `c854bf2` 2026-08-13 |
| Fix placeholders `project.yaml` (staging api_url, nombres MCP) | `7d058ff` / `8b41ceb` 2026-08-14 |
| Comando `/project-status` | `1d69608` 2026-08-14 |
| `/project-discovery` fases 1-4 para Bunkai TMS | `1f8ce57` 2026-08-17 |
| Sync inicial del PBI cache desde Jira | `5bd9146` 2026-08-18 |
| Business context maps + master test plan | `a7df185` 2026-08-26 |
| Fix jira issue type por id ("Historia" vs "Story") | `afb37e8` 2026-08-26 |
| Alineación MCP context7/dbhub cross-harness (regresiona en cada `bun run up`) | `b782662` 2026-08-26 |
| Migración de instancia Jira a upexgalaxy72 (url + catálogos) | `2ad69e8`..`143dce9` 2026-09-03 |

---

## Prácticas por historia (resumen — detalle en README)

| Práctica | Skill | Estado |
|---|---|---|
| BK-509 — Create a project inside a workspace | `shift-left-testing` | Cerrada 2026-08-26 (3 fases) |
| BK-859 — Leave a workspace | `sprint-testing` | Cerrada 2026-09-10 (pasos 1-7; paso 8 y fixtures C/D fuera de alcance) |
