# Piezas de canal

Textos que se publican afuera. Cada uno deriva de `../fundamento.md`; ninguno se
escribe de cero.

## Flujo

```
fundamento.md  ->  pieza (acá)  ->  forma del canal (../README.md)  ->  publicado
```

## Estados

Se marca en el encabezado de cada archivo.

| Estado | Significa |
|---|---|
| `borrador` | en escritura, no se muestra |
| `revisión` | escrito, esperando el visto de César |
| `aprobada` | lista para publicar |
| `publicada` | ya afuera. Se anota fecha y enlace |

## Nombres de archivo

`NN-slug-corto.md`, numerado por orden de publicación prevista. Ejemplo:
`01-por-que-un-rol-hibrido.md`. El número no se reusa aunque una pieza se descarte.

## Encabezado obligatorio

Cada archivo abre con este bloque. Es lo que permite auditar una pieza sin releerla entera.

```markdown
> **Estado:** borrador
> **Canal:** LinkedIn
> **Pilar:** 2 · Rol + IA asistida
> **Eje:** skill | dirigido a mano
> **Evidencia:** fila de `fundamento.md` §5 que la respalda
```

El campo `Eje` sirve para vigilar el balance 50/50 del inventario a lo largo de la serie,
no pieza por pieza.

## Antes de dar una pieza por terminada

Se corre el checklist de `../fundamento.md` §7. Sin excepciones.

## Carpetas

| Carpeta | Canal |
|---|---|
| `linkedin/` | posts. Tema visual B |
| `sitio/` | páginas de `cescolqa.github.io`. Tema visual C |

## Paquete de publicación (unidad de cierre)

Idea de César, 2026-09-21. Una pieza no se da por terminada cuando el deck está
construido, sino cuando sus salidas de canal están resueltas juntas. El deck es
el insumo; la publicación es el entregable.

Un paquete reúne, para una misma pieza:

| Salida | Qué se decide |
|---|---|
| Deck | ya construido y verificado en `../presentaciones/<deck>/` |
| Selección para LinkedIn | qué slides entran al carrusel, en qué orden y cuántas. No van todas por defecto: entran las que sostienen la idea del post |
| Post de LinkedIn | el texto que acompaña al carrusel, en `linkedin/NN-slug.md` |
| Página del sitio | la versión de profundidad, en `sitio/NN-slug.md` |
| Presencia en GitHub | qué se muestra desde el repositorio y qué queda solo enlazado |

**Por qué se resuelven juntas.** Las tres salidas hablan del mismo trabajo con
distinta profundidad, y si se escriben por separado terminan repitiendo la misma
frase o contradiciéndose en el nivel técnico. Decidirlas en una pasada es lo que
permite que el post traiga, el sitio sostenga y el repositorio pruebe.

**Controles del paquete**, además del checklist de `../fundamento.md` §7 sobre
cada salida:

- las tres salidas no repiten la misma tesis literal
- el post no depende de la página para entenderse, y la página no depende del post
- el nivel técnico sube de LinkedIn a sitio a repositorio, nunca al revés
- la selección de slides se justifica en una línea: por qué entra cada una

**Primer paquete previsto:** `onboarding-tecnico`. Es la pieza más cerrada y la
que ya pasó por dos rondas de ajuste, así que sirve de molde para los siguientes.

**Cadencia.** Cada publicación pide su propia pasada de revisión y afinado. El
pipeline evita empezar de cero cada vez; no reemplaza el pulso de cada semana.
