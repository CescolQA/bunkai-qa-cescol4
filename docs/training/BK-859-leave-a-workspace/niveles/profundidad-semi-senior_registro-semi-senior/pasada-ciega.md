# BK-859 "Leave a workspace" - Pasada ciega (diseño de pruebas)

> Paso 4 de la práctica de sprint-testing. Lo llenás **vos, a mano, sin IA**.
> Es tu charter de pruebas: qué probarías y por qué, partiendo solo del contexto de negocio.

## Reglas de la pasada

**Podés leer:**
- `business-context-brief.md`
- `rampa-de-arranque.md`
- `modelo-de-roles-y-membership.md`

**NO abrir hasta terminar esta pasada:**
- `implementation-plan.md`
- `acceptance-test-plan.md`
- `reconocimiento-hallazgos-SELLADO.md`
- la resolución real de BK-90 (defectos históricos)

Cuando termines esto, recién ahí abrís el doc sellado y hacés la pasada asistida (paso 5). Después se comparan las dos contra el resultado real (paso 7).

---

## 1. La feature en mis palabras

_(2-4 líneas: qué hace, para quién, qué la hace no trivial)_


## 2. Qué probaría - condiciones e ideas de test

_(lista libre. Una idea por línea. No te censures, después se ordena)_

-
-
-


## 3. Escenarios por forma de membership

_(para cada forma: qué hago, qué espero que pase)_

| Forma | Qué intento | Resultado que espero |
|---|---|---|
| Única membresía |  |  |
| Sole owner |  |  |
| Co-owner (queda otro owner) |  |  |
| Member no-owner |  |  |


## 4. Edge cases / límites que veo

_(bordes, concurrencia, orden de operaciones, estados raros)_

-
-


## 5. Riesgos

_(qué pasa si esto sale mal: usuarios afectados, datos, seguridad, negocio. Nivel: LOW / MEDIUM / HIGH / CRITICAL + por qué)_


## 6. Supuestos que hago

_(donde el brief no dice, qué asumo para poder diseñar)_

-
-


## 7. Preguntas abiertas / ambigüedades

_(lo que le preguntaría al PO o al dev antes de ejecutar)_

-
-


## 8. Notas y enfoque

_(qué priorizaría, qué técnica de diseño aplicaría dónde: EP, BVA, state-transition, decision table, pairwise, error-guessing)_

