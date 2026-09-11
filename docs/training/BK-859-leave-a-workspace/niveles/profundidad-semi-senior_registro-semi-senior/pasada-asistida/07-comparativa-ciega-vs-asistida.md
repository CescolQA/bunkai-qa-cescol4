# Comparativa — trabajo manual (pasada ciega) vs. pasada asistida

> Cierre del punto de comparación de la práctica BK-859.
> - **Ciega**: diseño de pruebas hecho a mano solo con el brief de negocio (`../pasada-ciega-completada.md`).
> - **Asistida**: diseño con el reconocimiento técnico sellado + técnicas formales (`06d-matriz-de-casos-v4.md`).
> - **Real**: respaldo de los 7 casos que se llegaron a ejecutar contra staging (`08-ejecucion-fixtures-A-B.md`). Se cita donde aporta.

## Alcance de esta comparativa

**Cerrada.** No se montaron los fixtures C (co-owner) ni D (member invitado), y los 12 casos que dependen de ellos no se ejecutaron. Fue una **decisión de alcance de la práctica**, no una deuda: el objetivo era comparar las dos formas de diseñar pruebas, y para eso los 7 casos ejecutados + la lectura de código y specs alcanzan.

---

## 1. Tabla de diferencias

| Dimensión | Pasada ciega (manual) | Pasada asistida | Qué dijo el testing real |
|---|---|---|---|
| **Técnicas** | BVA, State-Transition, Pairwise (marcadas, no desplegadas) | EP, BVA, State-Transition, Decision Table, Error-Guessing. Pairwise descartada con fundamento (los guards se evalúan en cadena) | — |
| **Nivel de detalle** | Ideas y formas de membership en tabla. Explícito: "aplicaría los mínimos y esenciales casos" | 28 casos con ID, precondición, resultado esperado, capa, prioridad y naturaleza | 7 casos ejecutados, 7 PASS |
| **Formas de membership** | 4 identificadas (única, sole owner, co-owner, member no-owner) — correcto | Las mismas 4, + `admin` cuenta como no-owner para el guard | Sole owner verificado (bloqueo OK). Co-owner y member no-owner: fuera de alcance |
| **Orden de los guards** | No considerado | Caso dedicado (TC-11): única membresía + sole owner debería devolver `last_membership` | El RPC confirma el orden por código. En vivo no se aisló (el guard cuenta mal si hay workspaces borrados — ver DEF-1) |
| **Códigos de error de la API** | No mencionados | 4 HTTP (`401`/`403`/`404`/`409`) mapeados a su causa | Verificados: `401` sin sesión, `403` con PAT, `404` inexistente, `404` no-miembro, `409` sole_owner |
| **Los dos `409`** | No detectado | Marcado como *improvement candidate*: ¿se distinguen? (TC-08) | **Resuelto**: sí se distinguen, por `details.reason` Y por `message`. El improvement queda descartado |
| **Segundo intento de leave** | No considerado | TC-24: debe dar `404`, no `500` | Fuera de alcance (necesita un leave que se complete) |
| **Workspace activo tras irse** | Mencionado como "que haya claridad" | TC-04 / TC-05: nuevo activo = `joined_at asc` + rotación de cookie; distinción activo vs no-activo | Fuera de alcance |
| **PAT** | No mencionado | TC-13 / TC-14: se revoca solo el PAT con scope del workspace que se deja | Fuera de alcance. La revocación en sí está en la spec (New Scenario B) y en el código del RPC |
| **Ruta agéntica** | Marcada como edge case ("instrucciones alternativas por IA agéntica") — buena intuición | TC-26: la IA pasa por los mismos guards, sin bypass | Fuera de alcance (acceso a la ruta a confirmar) |
| **Nivel de riesgo** | ALTO | ALTO | Coherente: los dos defectos hallados afectan integridad de acceso |

---

## 2. Qué acertó la pasada ciega sin ayuda

- Identificó las **4 formas de membership** correctas y qué se espera de cada una. La tabla de la sección 3 de la ciega tiene la misma estructura que la Decision Table de la asistida.
- Marcó el **riesgo ALTO** con un argumento válido (funcionalidad central y padre).
- Intuyó el **riesgo de la ruta agéntica** antes de ver que el RPC es `SECURITY DEFINER`.
- Detectó que el **núcleo es API, no UI**, y que eso es lo que la hace no trivial.
- Sus **preguntas abiertas** para PO y Dev siguen siendo pertinentes.

## 3. Qué agregó la pasada asistida

- **Bajó a matriz ejecutable**: 28 casos con precondición, resultado esperado, capa, prioridad y naturaleza. La ciega quedó en el nivel de "ideas".
- **Cobertura de contrato de API**: los 4 códigos, PAT → `403`, UUID inexistente, estados `invited` / `suspended`. Nada de esto estaba en la ciega.
- **Precedencia de guards** como caso explícito (TC-11).
- **Detectó el *improvement candidate*** de los dos `409` (que el testing real después cerró).
- **Efectos colaterales del `200`** como casos separados: cookie, PAT propio vs de otro workspace, hard delete, nuevo activo por `joined_at`.
- **Segunda vista de cobertura** (por dimensión de calidad), que permite elegir por dónde empezar cuando el tiempo es acotado.

## 4. Qué agregó el testing real que ningún diseño alcanzó

Los dos diseños miran **una historia**. El testing real, al tocar la app, cayó en la **costura entre dos historias** (BK-859 leave ↔ BK-512 delete):

| Hallazgo | Qué es |
|---|---|
| **Improvement descartado** | La asistida sospechaba que los dos `409` no se distinguían. En vivo se ve que sí: `details.reason` (`sole_owner` / `last_membership`) + `message` distinto. No hay improvement que elevar |
| **DEF-1** | Borrar un workspace (soft-delete) no toca las membresías. El guard `last_membership` de "Leave" las sigue contando → una cuenta puede quedar sin workspaces vivos + el mensaje de bloqueo es el equivocado. Causa: la migración del guard es anterior al modelo soft-delete |
| **DEF-2** | El campo "Business Rules" de BK-512 quedó viejo: dice "borrado inmediato e irreversible, sin restore", contra sus propias ACs + ADR-0015 + el diálogo en staging |

Ambos comentados en `BK-859` (versión resumida). No cargados como issues.

---

## 5. Lecturas de la práctica

- **La ciega acierta lo grande por instinto**: riesgo, dónde está el núcleo, las formas de membership, hasta el riesgo agéntico. Lo que no da: casos concretos, códigos, precedencia, efectos colaterales.
- **La asistida convierte instinto en cobertura**: mismas ideas, ahora ejecutables, con técnica y prioridad. Y ve un problema (los dos `409`) que la ciega no.
- **El testing real hace lo que ningún diseño hace**: confirma o descarta hipótesis (cerró el improvement) y encuentra lo que vive entre historias (DEF-1, DEF-2). El diseño, mirando una sola AC, no llega ahí.
- **Coinciden en el riesgo ALTO**: la ciega por instinto, la asistida por análisis, el testing real con dos defectos de integridad de acceso que lo respaldan.
