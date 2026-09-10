# Checkpoint 3 — State-Transition

> **Qué es**: modelar la entidad como una máquina de estados (estados + transiciones permitidas) y probar tanto las transiciones válidas como los **intentos de transición inválida** (sneak paths).
> **Disparador**: hay entidades con estado que cambia por acciones. Acá hay **tres**: la membership, el workspace activo del usuario y el PAT.
> **Para qué acá**: "Leave" es una transición. Interesa qué pasa antes, después, y si se puede repetir.

---

## 1. Máquina de estados — la membership (`workspace_members` row)

```
  [no existe] --invitación--> (invited) --aceptar--> (active) --leave--> [borrada / no existe]
                                                        |
                                                        +--suspender--> (suspended) --reactivar--> (active)
```

Estados: `invited`, `active`, `suspended`, y el estado implícito `[borrada]` (la fila no existe).

**Clave (H2)**: `leave` hace **hard delete**. No pasa por `suspended`. Después de `leave`, la fila **no existe**. Eso es distinto de suspender, que retiene la fila.

| Caso | Transición | Desde | Acción | Esperado |
|---|---|---|---|---|
| ST-1 | válida | `active` (co-owner) | leave | Fila borrada (hard delete). Validar por DB que **no existe** |
| ST-2 | válida | `active` (member no-owner) | leave | Igual que ST-1 |
| ST-3 | **bloqueada** | `active` (sole owner, 2+ membresías) | leave | `409` `sole_owner`. La fila **sigue** `active` |
| ST-4 | **bloqueada** | `active` (única membresía) | leave | `409` `last_membership`. La fila sigue `active` |
| ST-5 | **inválida (sneak path)** | `[borrada]` | leave otra vez sobre el mismo workspace | `404` `not_a_member`. No un `500`, no "borrar dos veces" |
| ST-6 | inválida | `invited` (invitación sin aceptar) | leave | `404` — no hay fila `active` |
| ST-7 | inválida | `suspended` | leave | `404` — la fila existe pero no está `active` |

---

## 2. Máquina de estados — el workspace activo del usuario (cookie `bk_active_ws`)

```
  (activo = WS_target) --leave WS_target--> (activo = membership restante más vieja por joined_at asc)
  (activo = WS_otro)   --leave WS_target--> (activo = WS_otro, sin cambio)
```

| Caso | Desde | Acción | Esperado |
|---|---|---|---|
| ST-8 | activo apunta a `WS_target`, quedan 2+ workspaces | leave `WS_target` | Response trae `newActiveWorkspaceId`/`Name` = el más viejo restante. La cookie `bk_active_ws` **cambia de valor**. El chrome global / switcher refleja el nuevo (AC S1) |
| ST-9 | activo apunta a `WS_otro` (no el target) | leave `WS_target` | `newActiveWorkspaceId` = sigue siendo `WS_otro`. La cookie **no cambia** |
| ST-10 | activo apunta a `WS_target`, y tras irse queda **1 solo** workspace | leave `WS_target` | El nuevo activo es ese único restante. (No confundir con Scenario A: acá el usuario tenía 2+, se va de uno, le queda 1) |

---

## 3. Máquina de estados — el PAT con scope del workspace (`access_tokens` row)

```
  (revoked_at = null / activo) --leave del workspace del scope--> (revoked_at = now() / revocado)
  (revoked_at = null, scope de OTRO workspace) --leave--> (sin cambio)
```

| Caso | Desde | Acción | Esperado |
|---|---|---|---|
| ST-11 | PAT activo con scope de `WS_target` | leave `WS_target` | `revoked_at` pasa a `now()` en la **misma transacción**. Usar ese PAT después → `401` |
| ST-12 | PAT activo con scope de `WS_otro` | leave `WS_target` | Ese PAT **no cambia**. Sigue devolviendo `200` en sus llamadas (H4) |
| ST-13 | PAT ya revocado antes del leave | leave `WS_target` | Sin efecto adicional (ya estaba revocado). No error |

---

## 4. Error-Guessing — sneak paths por experiencia

Casos que no salen de la máquina de estados "de manual" pero la experiencia dice que hay que mirar.

| Caso | Idea | Esperado |
|---|---|---|
| EG-1 | **Ruta agéntica sin bypass.** Pedirle a la IA agéntica que "saque al usuario del workspace" cuando es sole owner o única membresía | La IA llega al mismo RPC `SECURITY DEFINER`; los 4 guards actúan igual. Debe fallar con `409`, no ejecutar el `DELETE` |
| EG-2 | **Doble submit / doble click** en el botón "Leave workspace" de la UI | La primera request da `200`; la segunda debe dar `404` (fila ya borrada), no un `500` ni un estado inconsistente |
| EG-3 | **Race: dos co-owners se van casi a la vez** del mismo workspace, dejándolo con 0 owners | Uno de los dos debe recibir `409` `sole_owner` (el guard 4 se evalúa dentro de la transacción). El workspace nunca debe quedar con 0 owners activos (BR-8) |
| EG-4 | **Leave con el UUID en otra capitalización / con espacios** | `404` o `400` limpio, no un `500` |
| EG-5 | **Usuario deja el workspace mientras tiene una operación larga en curso** en ese workspace (ej. una corrida de ATCs) | Definir con Dev el esperado. Anotar como pregunta si no hay respuesta |

---

## Qué revisar en este checkpoint

- [ ] Las tres máquinas de estado (membership, workspace activo, PAT) tienen sus transiciones válidas y bloqueadas cubiertas
- [ ] El **segundo intento de leave** (ST-5) está probado y el esperado es `404`, no un error de servidor
- [ ] Los estados `invited` y `suspended` como origen del leave (ST-6, ST-7) devuelven `404`
- [ ] La re-resolución del workspace activo distingue "dejé el activo" (ST-8) de "dejé un no-activo" (ST-9)
- [ ] El PAT de otro workspace (ST-12) queda explícitamente fuera del alcance de la revocación
- [ ] Los sneak paths de Error-Guessing (EG-1 ruta agéntica, EG-3 race de co-owners) están anotados aunque sean difíciles de montar
