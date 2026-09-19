# Guiones — deck `project-discovery`

> **DECISIÓN (2026-09-19): guion A, con dos ajustes.** Versión final en
> `guion-definitivo.html`. Los tres guiones de abajo quedan como registro de los
> ángulos evaluados; no se editan.
>
> | Ajuste | Qué cambió |
> |---|---|
> | Slide 3 | sale "elegí el lento". La decisión se reencuadra como trazabilidad: "Elegí el camino que deja rastro". La lentitud no es argumentable ante quien evalúa |
> | Slide 9 | el cierre de A se reemplaza por el de B y C, más potente. Retocada una línea para no repetir la tesis de la slide 8 |
> | Slides 1-3 | reescritas: el contexto adverso deja de ser absoluto (sí hay quien te explique, sí hay a quién preguntar) y se dosifica a una línea |
> | Encuadre | resuelto por camino B (ver `encuadre-opciones.html`): la portada y la slide 2 absorben el marco, sin slide nueva. El deck se mantiene en 9 |

> Ninguna pieza anuncia la siguiente: cada guion cierra con su propia idea. La
> secuencia y la invitación a seguir van en el texto de publicación.
>
> Tres guiones, un solo fundamento. Los tres cumplen `../../fundamento.md`: regla
> de sujeto, evidencia con fila en el inventario, búsqueda laboral implícita.
> Se elige uno antes de escribir HTML.

## En qué se diferencian

| | A · El método | B · La garantía | C · El recorrido con tesis |
|---|---|---|---|
| Orden | cronológico: cómo se hizo el trabajo | argumentativo: tesis primero, prueba después | enmarcado: tensión, recorrido, prueba |
| Abre con | la situación de entrar sin contexto a un proyecto | la pregunta que hoy se hacen las empresas sobre la IA | la pregunta, en una sola slide corta |
| Pilar destacado | 2 · Rol + IA asistida | 4 · Experiencia y criterio propio | 2 y 4 en partes iguales |
| Lo que deja | "así trabaja esta persona" | "esta persona es la que puede responder por el resultado" | "así trabaja, y por eso puede responder" |
| Gancho | medio. Se entiende mejor leído entero | alto. La primera slide ya planta la tensión | alto al abrir, sostenido por el recorrido |
| Densidad por slide | baja, una idea por slide | media | alta. Dos slides fusionan dos ideas |
| Riesgo | puede leerse como relato de proceso | si la tesis no convence, el resto pierde fuerza | si se recorta mal, queda cargado |
| Cierra con | la posibilidad del método | la garantía como idea | ambas, fundidas |

Ninguno es más honesto que otro. Los tres usan la misma evidencia, ordenada distinto.

---

## Guion A · El método

9 slides. 8 con el rol como sujeto.

| # | Slide | Qué dice | Sujeto | Eje | Evidencia |
|---|---|---|---|---|---|
| 1 | Portada | tipografía del nombre de la skill + logo. Kicker sobre el rol | ancla | n/a | n/a |
| 2 | El punto de partida | qué te dan al entrar a un proyecto, y qué no. El contexto del pasado casi nunca aparece | vos | criterio previo | experiencia de rol |
| 3 | La decisión de método | dos caminos: asumir lo razonable y avanzar, o parar cada vez que algo no tiene prueba. Elegí el segundo | vos | dirigido a mano | §5.2 |
| 4 | Lo que produjo la skill | 4 fases sobre un repositorio desconocido: PRD, SRS, glosario, 20+ subdominios | skill | skill | §5.2 |
| 5 | Lo que decidí encima | sin un solo workflow de CI, lo fácil era anotar "None". Extendí la fase y marqué `Unknown` lo que no tenía respaldo | vos | dirigido a mano | §5.2 |
| 6 | Lo que me armé aparte | la skill no da una lente para leer lo que produce. Construí el mapa de capas e integraciones con glosario llano | vos | dirigido a mano | §5.2 |
| 7 | Qué cambió después | al encarar la primera historia partí de un piso de análisis más alto que el que hubiera alcanzado solo | vos | testimonio | §5.4 |
| 8 | La tesis | no es usar IA, es dirigirla: saber qué pedir, juzgar lo que vuelve, decidir cuándo profundizar | vos | posicionamiento | §1 |
| 9 | Cierre | la idea que queda: leer un producto entero es posible cuando se decide no afirmar nada sin prueba | vos | posicionamiento | §1 |

---

## Guion B · La garantía

9 slides. 8 con el rol como sujeto.

| # | Slide | Qué dice | Sujeto | Eje | Evidencia |
|---|---|---|---|---|---|
| 1 | Portada | misma tipografía + logo. Kicker sobre la tensión, no sobre la skill | ancla | n/a | n/a |
| 2 | La pregunta | la IA ya produce análisis, casos y documentación. La pregunta abierta es quién garantiza que esté bien | vos | posicionamiento | §5.1 |
| 3 | Mi respuesta | trabajar de modo que cada afirmación se pueda auditar. Eso obliga a tener criterio antes, no después | vos | posicionamiento | §1 |
| 4 | Prueba 1 · el freno | corrí la skill sobre un producto desconocido y lo que no tenía evidencia quedó marcado `Unknown`. Modelo de ingresos, costos, competencia: sin respaldo, no se escriben | vos + skill | skill | §5.2 |
| 5 | Prueba 2 · la extensión | donde la skill cerraba rápido, no cerré. Sin CI, un cambio puede romper 135 tests sin que nadie se entere. Eso merecía documentarse, no un "None" | vos | dirigido a mano | §5.2 |
| 6 | Prueba 3 · la lente propia | lo que faltaba me lo construí: mapa de capas, integraciones y glosario llano, para poder leer lo que la herramienta produce | vos | dirigido a mano | §5.2 |
| 7 | Lo que la herramienta no vio | en la práctica siguiente, un punto lo detectó únicamente mi análisis a mano: los criterios de aceptación mezclaban nivel técnico con nivel funcional. Ni la IA ni el proceso real lo señalaron | vos | dirigido a mano | §5.3 |
| 8 | La tesis | el criterio propio no es decoración sobre la herramienta. Es lo que permite responder por el resultado | vos | posicionamiento | §1 |
| 9 | Cierre | la idea que queda: el criterio propio es lo que hace auditable lo que produce la herramienta | vos | posicionamiento | §1 |

---

## Guion C · El recorrido con tesis

9 slides. 8 con el rol como sujeto. Toma la apertura y el cierre de B, y el
recorrido de A, fusionando dos pares de slides para que entre en la misma
extensión.

| # | Slide | Qué dice | Sujeto | Eje | Evidencia |
|---|---|---|---|---|---|
| 1 | Portada | tipografía del nombre de la skill + logo. Kicker sobre la tensión | ancla | n/a | n/a |
| 2 | La tensión | la IA ya produce análisis y documentación. La pregunta abierta es quién responde por el resultado | vos | posicionamiento | §5.1 |
| 3 | El punto de partida | qué te dan al entrar a un proyecto, y qué no. El contexto del pasado casi nunca aparece | vos | criterio previo | experiencia de rol |
| 4 | La decisión de método | dos caminos: asumir lo razonable y avanzar, o parar cada vez que algo no tiene prueba. Elegí el segundo | vos | dirigido a mano | §5.2 |
| 5 | Lo que produjo la skill, y el freno | 4 fases sobre un repositorio desconocido: PRD, SRS, glosario, 20+ subdominios. Lo que no tenía evidencia quedó marcado `Unknown` | vos + skill | skill | §5.2 |
| 6 | Donde no cerré | sin un solo workflow de CI, lo fácil era anotar "None". Extendí la fase: un cambio puede romper 135 tests sin que nadie se entere | vos | dirigido a mano | §5.2 |
| 7 | La lente que me armé | la skill no da con qué leer lo que produce. Construí el mapa de capas, integraciones y glosario llano | vos | dirigido a mano | §5.2 |
| 8 | Lo que la herramienta no vio | en la práctica siguiente, un punto lo detectó únicamente mi análisis a mano: los criterios mezclaban nivel técnico con funcional. Por eso el criterio propio no es decoración | vos | dirigido a mano | §5.3 + §1 |
| 9 | Cierre | la idea que queda: el criterio propio es lo que hace auditable lo que produce la herramienta | vos | posicionamiento | §1 |

---

## Checklist antes de pasar a HTML

Se corre sobre el guion elegido, no sobre el HTML terminado.

- [ ] Proporción de sujeto: mínimo 2 de cada 3 slides sobre el rol.
- [ ] Cada slide de contenido cita una fila del inventario `fundamento.md` §5.
- [ ] Ninguna slide afirma capacidad de una etapa no iniciada.
- [ ] Búsqueda laboral implícita en todo el deck.
- [ ] Una idea por slide.
