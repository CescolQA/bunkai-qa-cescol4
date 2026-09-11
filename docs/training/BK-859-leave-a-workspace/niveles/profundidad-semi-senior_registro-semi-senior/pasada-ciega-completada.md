# BK-859 "Leave a workspace" - Pasada ciega (completada)

- Autor: César C
- Iniciado: 2026-09-08T17:51:54.910Z
- Exportado: 2026-09-09T14:11:45.186Z

## 1. La feature en mis palabras

La feature trata de la funcionalidad de dejar un workspace. Esta dirigida para el rol de owner. Lo que no la hace trivial es que su nucleo no es a través de la interfaz, si no a traves de API principalmente.

## 2. Que probaria - condiciones e ideas de test

Escenario en UI para poder habilitar el Eliminar / Dejar un workspace
La creación de un nuevo workspace adicional , sumando nuevos miembros a través de API
Intentar Eliminar / dejar workspace en escenarios donde no se debería permitir

## 3. Escenarios por forma de membership

| Forma | Que intento | Resultado que espero |
|---|---|---|
| Unica membresia | Dejar el Workspace | No debería ocurrir |
| Sole owner | Dejar el Workspace | No debería ocurrir |
| Co-owner | Dejar el Workspace | Debería permitirse |
| Member no-owner | Dejar el Workspace | Debería permitirse |

## 4. Edge cases / limites

Escenarios donde pueda permitirse dejar el worskpace por instrucciones alternativas por IA Agentica
Que la funcionalidad / usuario tenga el conocimiento suficiente de lo que puede llegar por UI o por API
Que haya claridad en lo que se permite o no hacer dependiendo del rol, la membresía y el estado

## 5. Riesgos

Nivel: HIGH

Considero un nivel alto por que es una funcionalidad central y padre dentro de la aplicación y el negocio.
Si bien las interacciones centrales no son demasiadas y complejas, lo que si debería cumplir es con mucha claridad y sentido funcional

## 6. Supuestos

Asumo que muchas de los escenarios API están habilitados y disponibles para poder cubrir hacer las pruebas
Que hay una marcada y suficiente consideración de seguridad para el manejo de datos manual, por API y la IA Agentica
Que el diseño de roles, miembros y estado cumplen con una lógica funcional bien pensada, suficiente y establecida

## 7. Preguntas abiertas / ambiguedades

PO: 
Porqué la lógica de diseño funcional y datos va más por el lado de API's que por la parte UI
Es necesario cubrir y construir todos los escenarios de roles, miembros, y estados en esta primera etapa de pruebas?

DEV: 
Los contratos de la API y las interacciones que tengan con la IA agentica están consideradas?
En que estado de construcción o terminados están las API vinculadas a este desarrollo? Están listas y preparadas para compartir y hacer las pruebas de los primeros escenarios?

## 8. Notas y enfoque

Tecnicas marcadas: BVA, State-Transition, Pairwise

Aplicaría los mínimos y esenciales casos que cubran objetivamente la funcionalidad en primer lugar. Centrándome en las técnicas seleccionadas.
