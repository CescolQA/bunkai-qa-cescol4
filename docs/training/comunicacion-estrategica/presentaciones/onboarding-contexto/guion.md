# Guiones — deck `onboarding-contexto` (reescritura)

> **Estado: tres guiones propuestos, sin elección.** El deck vigente
> (`onboarding-contexto.html` y sus variantes B y C) no se toca ni se elimina:
> queda como registro de la versión anterior al fundamento.
>
> Motivo de la reescritura: el deck se construyó antes de `../../fundamento.md` y
> no pasó por la regla de sujeto. Auditoría del 2026-09-21: 6 de 9 slides con el
> rol como sujeto, tres fallas duras (slide 4 es ficha de producto, slides 7 y 9
> anuncian la próxima pieza y ya están vencidas), pilares nombrados en pantalla,
> eje manual ausente y `Documentación` mostrada como etapa en práctica.

## Qué es este deck y qué lo diferencia del resto

Es la única pieza cuyo tema ES el conjunto. No recorta una skill: presenta el
recorrido completo. Eso le da una libertad que ninguna otra tiene (puede hablar
de las tres prácticas a la vez) y una trampa propia: es la pieza donde más fácil
resulta que el sujeto se corra del rol al producto o a la serie.

## Decisiones declaradas antes de escribir

| Decisión | Por qué |
|---|---|
| El producto entra como escenario, nunca como slide propia | `fundamento.md` §3. Bunkai TMS se define al pasar, en una línea, dentro de la slide donde se cuenta qué se eligió entrenar |
| Ningún cierre anuncia la próxima pieza | `fundamento.md` §6 dice que ninguna pieza anuncia la siguiente. `README.md` exceptúa al onboarding, pero la excepción ya caducó una vez: el deck vigente promete `project-discovery` como "próxima entrega" y ese deck existe desde el 2026-09-19. La invitación a seguir va en el texto de publicación, que se cambia sin tocar el deck |
| Los pilares no se nombran en pantalla | regla del `README.md` (2026-09-19). El panorama se arma por recorrido o por eje, no por numeración interna |
| El eje manual aparece sí o sí | `fundamento.md` §5.1. El deck vigente no menciona una sola cosa hecha sin IA, que es justo lo que sostiene el diferencial |
| Las etapas no iniciadas se nombran como próximo paso | `fundamento.md` §5.6. `test-documentation`, `test-automation` y `regression-testing` no entran en ninguna flecha de recorrido practicado |
| Portada con la imagen completa del producto | `README.md`. Es el único deck al que le corresponde |
| Archivo nuevo, el viejo queda | el nombre lleva el recorte del guion elegido (`onboarding-<recorte>.html`), no un ordinal |

## En qué se diferencian

| | A · El recorrido | B · La garantía | C · El recorrido con tesis |
|---|---|---|---|
| Orden | cronológico: etapa por etapa del entrenamiento | argumentativo: una tensión y dos ejes que la responden | enmarcado: tensión primero, recorrido después |
| Abre con | de dónde viene el criterio, antes de la IA | la pregunta que hoy tienen abierta las empresas con IA | la misma pregunta, en una slide corta |
| Organiza el panorama por | etapas del pipeline practicadas | ejes (lo que corre la skill / lo que se dirige a mano) | etapas, con el eje manual dentro de cada una |
| Deja al lector | "esta persona recorrió un camino completo" | "esta persona puede responder por el resultado" | "recorrió el camino, y por eso puede responder" |
| Gancho | medio. Crece hacia el final | alto. La primera slide plantea la tensión | alto al abrir, sostenido por el recorrido |
| Densidad por slide | baja, una idea por slide | media | alta. Tres slides fusionan dos ideas |
| Riesgo | puede leerse como bitácora de avance | el panorama queda menos visible: se ven ejes, no etapas | si se recorta mal, queda cargado |
| Balance 50/50 | por slide: cada etapa muestra lo corrido y lo dirigido | estructural: un eje por bloque | dentro de cada etapa |

Los tres usan la misma evidencia de `../../fundamento.md` §5, ordenada distinto.
Ninguno afirma nada que no tenga fila en el inventario.

---

## Guion A · El recorrido

9 slides. 9 con el rol como sujeto.

| # | Slide | Qué dice | Sujeto | Eje | Evidencia |
|---|---|---|---|---|---|
| 1 | Portada | imagen del producto + kicker del rol. Título sobre lo que se está entrenando, no sobre el producto | ancla | n/a | n/a |
| 2 | De dónde viene el criterio | analista funcional y analista de pruebas, con recorrido propio. Lo que hay debajo no nació con la IA | rol | criterio previo | §1 ancla 1 |
| 3 | Qué elegí entrenar | no un curso: un producto real, con historias y defectos reales, y el rol completo encima. Bunkai TMS definido en una línea, como escenario | rol | dirección | §1 ancla 2 |
| 4 | Leer un producto desde cero | corrí las 4 fases de discovery sobre un repositorio desconocido, y marqué `Unknown` todo lo que no tenía respaldo en vez de completarlo | rol + skill | skill + a mano | §5.2 |
| 5 | Refinar antes de que exista el bug | analicé una historia a ciegas, sin IA, antes de correr nada. Después la refiné con la skill y comparé las dos contra la resolución real de producción | rol | a mano + skill | §5.3 |
| 6 | Probar de verdad | diseñé los casos a ciegas y los sellé antes de abrir el material asistido. Monté los fixtures a mano en Postman. 7 casos ejecutados, 2 defectos encontrados | rol | a mano + ejecución real | §5.4 |
| 7 | Lo que me armé por fuera | ninguna skill lo pidió: mapa de capas e integraciones, rampa de arranque, checklist de madurez, backlog propio de entrenamiento | rol | a mano | §5.5 |
| 8 | Dónde estoy hoy | tres etapas cerradas con evidencia; documentación, automatización y regresión todavía sin tocar. Dicho así, no insinuado | rol | honestidad | §5.6 |
| 9 | Cierre | no es usar IA, es dirigirla: saber qué pedir, juzgar lo que vuelve, decidir cuándo profundizar | rol | posicionamiento | §1 |

---

## Guion B · La garantía

9 slides. 9 con el rol como sujeto.

| # | Slide | Qué dice | Sujeto | Eje | Evidencia |
|---|---|---|---|---|---|
| 1 | Portada | imagen del producto + kicker sobre la tensión, no sobre el recorrido | ancla | n/a | n/a |
| 2 | La pregunta abierta | las empresas ya instalaron IA. El problema que queda no es generar salida, es garantizar que esa salida sea correcta | rol (tesis) | posicionamiento | §5.1 |
| 3 | Cómo me entreno para eso | dos ejes en partes iguales: correr el instrumental nuevo, y hacer a mano lo suficiente como para poder auditarlo. Sobre un producto real, definido acá en una línea | rol | dirección | §5.1 |
| 4 | Eje 1 · lo que corre la skill | discovery de 4 fases sobre un repositorio desconocido, refinamiento de criterios con el gate bloqueando el arranque, diseño de casos con técnicas formales aplicadas | skill | skill | §5.2 · §5.3 · §5.4 |
| 5 | Eje 2 · lo que hago a mano | análisis ciego antes de correr nada, sellado en commit para que la comparación sea legítima. Fixtures montados a mano para no depender del mismo instrumental | rol | a mano | §5.3 · §5.4 |
| 6 | La prueba de que el eje manual sirve | en la comparación de tres vías hay un punto que detectó únicamente el análisis humano: los criterios mezclaban nivel técnico de API con nivel funcional. Ni la IA ni el proceso real lo señalaron | rol | a mano | §5.3 |
| 7 | Lo que eso produce | 7 casos ejecutados con resultado correcto y 2 defectos reales encontrados en la aplicación. Más lo que me armé por fuera para poder leer lo que la herramienta devuelve | rol | ejecución real + a mano | §5.4 · §5.5 |
| 8 | Lo que todavía no está | documentación, automatización y regresión: no iniciadas. Decirlo es parte de la garantía, no una concesión | rol | honestidad | §5.6 |
| 9 | Cierre | el criterio propio no es decoración sobre la herramienta. Es lo que permite responder por el resultado | rol | posicionamiento | §1 |

---

## Guion C · El recorrido con tesis

9 slides. 9 con el rol como sujeto. Toma de B la apertura y el cierre, de A el
recorrido por etapas, y mete el eje manual dentro de cada etapa en vez de
separarlo en un bloque propio. Fusiona tres pares de slides para entrar en la
misma extensión.

| # | Slide | Qué dice | Sujeto | Eje | Evidencia |
|---|---|---|---|---|---|
| 1 | Portada | imagen del producto + kicker sobre la tensión | ancla | n/a | n/a |
| 2 | La pregunta abierta | la IA ya produce análisis, casos y documentación. Lo que queda abierto es quién responde por el resultado | rol (tesis) | posicionamiento | §5.1 |
| 3 | De dónde vengo y qué elegí | analista funcional y de pruebas; elegí entrenar el rol completo sobre un producto real, no sobre un curso. Bunkai TMS en una línea | rol | criterio previo + dirección | §1 |
| 4 | Leer un producto desde cero | corrí las 4 fases sobre un repositorio desconocido, y lo que no tenía respaldo quedó marcado `Unknown` en vez de completado | rol + skill | skill + a mano | §5.2 |
| 5 | Refinar antes del bug, y lo que la herramienta no vio | analicé la historia a ciegas antes de correr nada, y en la comparación de tres vías apareció un punto que solo vio el análisis humano: criterios que mezclaban nivel técnico con funcional | rol | a mano | §5.3 |
| 6 | Probar de verdad | casos diseñados a ciegas y sellados antes de abrir el material asistido, fixtures montados a mano, 7 casos ejecutados, 2 defectos encontrados | rol | a mano + ejecución real | §5.4 |
| 7 | Lo que me armé por fuera | mapa de capas, rampa de arranque, checklist de madurez, backlog propio. Nada de esto lo pidió una skill | rol | a mano | §5.5 |
| 8 | Dónde estoy hoy | tres etapas cerradas con evidencia; documentación, automatización y regresión sin iniciar | rol | honestidad | §5.6 |
| 9 | Cierre | el criterio propio es lo que hace auditable lo que produce la herramienta. Por eso el recorrido se hizo así | rol | posicionamiento | §1 |

---

## Checklist antes de pasar a HTML

Se corre sobre el guion elegido, no sobre el HTML terminado.

- [ ] Proporción de sujeto: mínimo 2 de cada 3 slides sobre el rol. Los tres guiones declaran 9 de 9.
- [ ] Cada slide de contenido cita una fila del inventario `../../fundamento.md` §5.
- [ ] Ninguna slide afirma capacidad de una etapa no iniciada.
- [ ] El producto aparece como escenario, nunca como sujeto de una slide.
- [ ] Los pilares no se nombran en pantalla.
- [ ] El balance entre lo corrido por la skill y lo dirigido a mano queda visible.
- [ ] Ningún cierre anuncia la próxima pieza.
- [ ] Búsqueda laboral implícita en todo el deck.
- [ ] Una idea por slide.
- [ ] Castellano neutro, sin voseo.
