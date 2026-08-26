# BK-509 - Mi análisis Shift-Left (ciego)

## Ambigüedades
En los AC hace referencia a la comunicación y transacción API, pero no tan en detalle de la transacción en la base de datos.

No deja  muy claro si el nombre que se puede colocar al workspace o proyecto puede ser alfanumérico.

Si rechaza un nombre del workspace duplicado, no queda claro si es un tema de mi usuario o de otros usuarios. De hecho una de las reglas de negocio aclara que dos workspaces distintos pueden tener el  mismo nombre. Parece esta la mayor ambiguedad encontrada entre los AC y las reglas de negocio. Tambien se percibe ambiguedad cuando se refiere a proyectos y cuando se refiere a workspaces. La US se refiere a workspaces pero en los AC habla de proyectos tambien.

La prohibición de que un usuario no puede crear un proyecto donde no es miembro, tambien debería especificarse para la base de datos.

## Gaps
La regla de negocio "name DEBE contener ≥1 carácter alfanumérico." es ambigua con respecto al AC

"Scenario: Name too short rejected
Given a workspace member
When they submit name "AB" (2 chars)
Then the system returns 400 with code NAME_TOO_SHORT (min 3 chars)"

Sumaría como mirada general que entre los AC, el Scope y las reglas de negocio parece una ensalada de definiciones y especificaciones intercaladas. El Scope debe ser más cualitativo por ejemplo. Las reglas de negocios mas claras y en concordancia mínima con los AC.

## Riesgo
HIGH - El nivel de riesgo es alto, pues es una funcionalidad primordial del producto.
No la clasifico critica por que en realidad no es algo complejo.

## Preguntas bloqueantes
Desde mi punto de vista observo que hay AC que se meten de una vez con el tema API's, endopoints, etc. Y por ahí haciendo shift left aún no están hechas las API's etc. Por un lado expresan que esta hecha o supone una parte técnica donde aún esta por desarrollarse. Capaz los AC deberían ser más funcionales o a nivel usuario.

## Notas
Para las pruebas enfocaría sobre los casos limites y bordes. Y por la intención y declaración que veo de las API le daría bastante importancia a las pruebas API.
