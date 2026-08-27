# Checklist de madurez del sistema — qué pedir antes de un Shift-Left Testing

> Documento transversal, no atado a una historia puntual ni a un stack o herramienta específica. Nace de la práctica sobre BK-509, pero aplica a cualquier historia futura. Complementa (no reemplaza) el catálogo de preguntas por tipo de historia — autenticación, dinero, búsqueda, máquina de estados, etc. Este documento resuelve una pregunta previa a todas esas: **¿esto ya existe o se está construyendo ahora?**

## Por qué existe

Un catálogo de preguntas por tipo de historia asume que ya sabés cuánto terreno está construido debajo de ella. En la práctica no siempre es así: la misma pregunta ("¿cuál es el modelo de datos?") tiene una respuesta muy distinta si hay una tabla en producción con datos reales, o si todavía no existe ni el borrador de un esquema. Pedir lo mismo en los dos casos es o quedarse corto, o hacer perder tiempo al equipo pidiendo algo que todavía no puede existir.

## Cómo usarlo

1. Hacé el diagnóstico rápido (sección 1) antes de leer la historia en detalle.
2. Elegí el checklist que corresponda — evolutivo, desde cero, o una mezcla de ambos (lo más común).
3. Las preguntas universales (sección 4) aplican siempre, sin importar el contexto.
4. Recién ahí pasá al catálogo de preguntas específico del tipo de historia (auth, dinero, búsqueda, etc.) — ese es otro documento, con otro propósito.

---

## 1. Diagnóstico — ¿dónde cae esta historia?

**Señales de contexto evolutivo** (ya hay algo construido):

- Existe una tabla o entidad de base de datos ya en producción o en un ambiente compartido, relacionada con esta historia.
- Hay al menos un endpoint de API ya publicado y consumido por algo.
- Hay código de referencia — aunque sea de una funcionalidad vecina — que ya resuelve un problema parecido.
- Hay usuarios reales con datos reales sobre esta entidad hoy.

**Señales de contexto desde cero** (greenfield):

- No hay tabla, ni esquema, ni una migración escrita todavía.
- No hay contrato de API definido, ni siquiera en borrador.
- No hay código de referencia — la funcionalidad es conceptualmente nueva.
- No hay usuarios ni datos reales que dependan de esto todavía.

Estos son los dos extremos. La mayoría de las historias reales caen en un punto intermedio, y eso es normal — no es que el diagnóstico haya fallado, es que el sistema mismo es una mezcla. Una historia puede sonar a "crear algo nuevo" en su título y, al mismo tiempo, apoyarse enteramente sobre un modelo de datos, un modelo de permisos y unas convenciones de API que ya llevan años madurando. Cuando eso pasa, tratala como evolutiva para todo lo que ya está maduro (datos, auth, convenciones) y como greenfield solo para la porción genuinamente nueva.

---

## 2. Checklist — contexto evolutivo (ya hay algo construido)

### Qué pedirle al equipo (desarrollo / liderazgo técnico)

- El modelo de datos real de la entidad afectada: columnas, tipos, restricciones — no alcanza con el nombre de la tabla.
- El contrato real de la API (request, response, códigos de error) si hay alguna sospecha de que difiere de lo que dice el ticket.
- Decisiones de arquitectura pasadas que condicionen esta historia: por qué se hizo así antes, qué alternativa se descartó y por qué.
- Historial de incidentes o defectos conocidos sobre esta misma entidad — para no repetir un problema ya resuelto, ni asumir que "nunca pasó" algo que sí pasó.

### Qué pedirle al proyecto (código existente)

- Qué pruebas automatizadas ya cubren esta entidad, para no duplicar cobertura ni asumir que "no probado" significa "no importa".
- Qué otras funcionalidades dependen de esta entidad — el radio de impacto si algo sale mal.
- Convenciones ya establecidas (nombres, validaciones, manejo de errores) que esta historia debería respetar por consistencia con lo que ya existe.

### Qué pedirle al producto (negocio / dueño del producto)

- Reglas de negocio no escritas que el sistema ya aplica hoy pero que el ticket no menciona — la brecha entre lo implementado y lo redactado suele esconder el bug.
- Impacto sobre datos y usuarios reales existentes: ¿hace falta migración, ventana de mantenimiento, aviso previo?
- El motivo de negocio real detrás del cambio. Una historia que parece chica a veces es el síntoma visible de un problema más grande que nadie puso por escrito todavía.

---

## 3. Checklist — contexto desde cero (greenfield)

### Qué pedirle al equipo

- Un borrador de modelo de datos propuesto, aunque sea informal, antes de escribir criterios de aceptación al detalle — sin eso, cualquier AC sobre validaciones es una suposición.
- Un borrador de contrato de API, aunque todavía no esté implementado, para poder anticipar códigos de estado y casos de error en el plan de pruebas.
- Qué decisiones de arquitectura siguen abiertas. Si hay más de una opción todavía sobre la mesa, el testing tiene que esperar a que se resuelva — no puede inventarse un comportamiento para llenar el vacío.

### Qué pedirle al proyecto

- Confirmar si de verdad no depende de nada existente, o si comparte alguna entidad, flujo o convención con una funcionalidad vecina. Casi nada es 100% aislado.
- Qué patrones ya establecidos en el resto del sistema deberían replicarse acá por consistencia, aunque el código puntual todavía no exista.

### Qué pedirle al producto

- Casos de uso reales o hipótesis de uso concretas: quién lo va a usar, con qué frecuencia, con qué volumen esperado.
- El criterio de éxito de negocio: qué métrica confirma que esto funcionó, no solo que "no rompió nada".
- Confirmación explícita de si el criterio de aceptación ya pasó por una revisión técnica, o si es la traducción literal de una idea de producto que todavía nadie validó con desarrollo. Si es lo segundo, decirlo antes de aceptar el ticket tal como está redactado.

---

## 4. Preguntas universales (aplican en cualquiera de los dos extremos)

- ¿Qué pasa en el peor caso — falla de red, doble clic, dato corrupto, dos personas actuando a la vez?
- ¿Quién tiene permiso para hacer esto, y qué le pasa a quien no lo tiene?
- ¿Qué significa "éxito" desde la interfaz que ve el usuario, no solo desde la respuesta técnica del servidor?
- ¿Esta operación se puede repetir sin efectos secundarios raros (idempotencia)?

Estas cuatro son la puerta de entrada, no el detalle completo. Una vez resuelto el diagnóstico de madurez de esta sección, cada tipo de historia (autenticación, dinero, búsqueda, máquina de estados, integración externa, etc.) tiene su propio catálogo de preguntas específicas — ese es un documento distinto, con un propósito distinto: este resuelve "¿qué terreno piso?", el otro resuelve "¿qué le falta a ESTA historia en particular?".

---

## 5. Regla de oro

Si no podés contestar "¿esto ya existe o se está inventando ahora?" en el primer minuto de leer la historia, esa es la primera pregunta a resolver — antes que cualquier otra, porque cambia todas las respuestas que siguen.
