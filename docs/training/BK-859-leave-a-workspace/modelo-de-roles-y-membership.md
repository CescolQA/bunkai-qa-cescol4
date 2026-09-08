# BK-859 - Modelo de roles y membership (companion de contexto)

> Artefacto de contexto para entrenamiento. Complementa `business-context-brief.md` y `rampa-de-arranque.md`.
> Objetivo: entender bien el modelo de roles / formas / estados de "workspace membership" antes de diseñar pruebas para "Leave a workspace".
> No es diseño de pruebas. Los casos concretos salen de la pasada ciega (paso 4) y la asistida (paso 5).
> Idioma castellano por convención de entrenamiento. Identificadores, tablas y enums, textuales.

---

## 1. Concepto base: "fixture"

Viene de los frameworks de test (xUnit). Un *test fixture* es el estado fijo y conocido del mundo que se deja preparado **antes** de ejecutar una prueba, para que el resultado sea repetible y signifique lo que uno cree.

En el patrón **Arrange - Act - Assert**, el fixture es todo el *Arrange*: datos, cuentas, relaciones y config montados a propósito.

| Término | Qué es |
|---|---|
| Fixture | estado montado a propósito para una prueba concreta (ej: "un workspace con 2 owners activos") |
| Test data | los valores sueltos que se usan adentro (un nombre, un slug) |
| Environment | la instancia donde corre todo (staging) |

- **Por qué importa**: si la prueba "un co-owner puede irse" corre sobre un workspace que tiene un solo owner, no se está probando lo que se dice.
- **Teardown**: el reverso. Al terminar, dejar el mundo como estaba (borrar lo creado) para no ensuciar la próxima corrida.
- **En KATA (este repo)**: la capa L4 `TestFixture` existe justo para esto: inyecta el estado y las dependencias que el test necesita.

## 2. Roles de membership (`workspace_members.role`)

Enum real, de `domain-glossary.md` (`0001_tenancy.sql:43-44`):

| Role | Qué es | Puede |
|---|---|---|
| `viewer` | miembro de solo lectura | nada de crear / editar / borrar recursos |
| `member` | contribuidor estándar | autorear y escribir en todo el workspace |
| `admin` | administrador del workspace | lo de `member` + gestionar miembros e invites |
| `owner` | dueño del workspace | control total; único que puede borrar el workspace; **siempre debe quedar >=1** (`0044_leave_workspace.sql`) |

Dato clave para fixtures: **`owner` NO es invitable**. Los invites solo otorgan `viewer | member | admin` (`0010_workspace_invites.sql:17-18`).

## 3. Estados de membership (`workspace_members.status`)

| Status | Significado | Acceso |
|---|---|---|
| `active` | membresía en vigor | otorga acceso |
| `invited` | invitación no aceptada todavía | sin acceso aún |
| `suspended` | membresía suspendida | sin acceso, pero la fila se retiene |

Contraste importante con "Leave": irse hace un **hard delete** de la fila. `suspended` retiene la fila. Son dos cosas distintas.

## 4. "Sole owner" y "co-owner" NO son roles: son situaciones

Son estados derivados de dos ejes:

- **Eje 1** - cuántos workspaces activos tengo
- **Eje 2** - si soy `owner` de este, cuántos otros owners activos hay

| Forma | Definición | Guard que toca al intentar "leave" |
|---|---|---|
| Única membresía | este es mi único workspace activo | `last_membership` |
| Sole owner | soy `owner` y no hay otro owner activo | `sole_owner` |
| Co-owner | soy `owner` y hay >=1 otro owner activo | ninguno (debería poder irse) |
| Member no-owner | mi role es `viewer` / `member` / `admin` | ninguno de los de owner |

Nota: un `admin` que se va cuenta como "member no-owner" para los guards. El guard mira `role='owner'`, no `admin`.

El schema **no impide** múltiples filas `owner` por workspace (sin unique index parcial). El guard es puro conteo.

## 5. Fixtures que convienen para BK-859

| Fixture | Cómo armarlo | Forma que habilita |
|---|---|---|
| A | Bunkai 3 tal cual (ya existe: user es sole owner + única membresía) | única membresía + sole owner (los dos bloqueos juntos) |
| B | 2do workspace propio: `POST /api/v1/workspaces` | ahora hay >=2, se levanta `last_membership` |
| C | B + un 2do owner en ese workspace | co-owner puede irse |
| D | otro user me invita a su workspace como `member` | member no-owner se va |

**Ojo con C (co-owner)**: es el más difícil de montar.
- No se puede invitar a nadie como `owner`.
- El reconocimiento no encontró endpoint para promover a owner.
- En staging, el segundo owner probablemente haya que insertarlo por DB.
- El rol `qa_inspector_rw` tiene `SELECT` + `DELETE` sobre `workspace_members`, no necesariamente `INSERT` / `UPDATE`. Verificar eso al llegar a fixtures.

## 6. Límite de este documento

Esto es el terreno: 4 formas de membership, hasta 4 guards, y los fixtures para llegar a cada una.

Lo que NO está acá a propósito: qué asertar, qué edge cases, con qué técnica de diseño. Eso es la pasada ciega (paso 4, solo con el brief) y la asistida (paso 5, con `reconocimiento-hallazgos-SELLADO.md`).
