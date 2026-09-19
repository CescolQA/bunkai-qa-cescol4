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
