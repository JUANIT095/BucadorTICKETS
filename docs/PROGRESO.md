# PROGRESO DEL PROYECTO — BuscadorTickets

Leyenda: `[x]` completada · `[ ]` pendiente

| # | Fase | Estado | Fecha | Notas |
|---|------|--------|-------|-------|
| 1 | Análisis del contexto | [x] | 2026-09-30 | Casos límite en `ARQUITECTURA.md` §9. |
| 2 | Arquitectura | [x] | 2026-09-30 | Aprobada y guardada en `docs/ARQUITECTURA.md`. |
| 3 | Configuración Flutter Windows | [ ] | | Incluye: `BINARY_NAME` → `BuscadorTickets`, quitar `cupertino_icons`, agregar `path` (y `file_selector`). |
| 4 | Interfaz | [ ] | | |
| 5 | Selección de carpeta raíz | [ ] | | |
| 6 | Detección de años | [ ] | | Crear aquí el modelo `Ticket` mínimo si hace falta. |
| 7 | Detección de meses | [ ] | | |
| 8 | Detección de tickets | [ ] | | |
| 9 | Modelo de datos | [ ] | | Completar `Ticket` (toJson/fromJson, campos normalizados). |
| 10 | Indexación | [ ] | | |
| 11 | Motor de búsqueda | [ ] | | |
| 12 | Resultados | [ ] | | Conteo de elementos bajo demanda para tarjetas visibles. |
| 13 | Abrir carpeta | [ ] | | Probar rutas largas y con comas. |
| 14 | Copiar ruta | [ ] | | |
| 15 | Filtros | [ ] | | |
| 16 | Optimización | [ ] | | |
| 17 | Pruebas | [ ] | | |
| 18 | Build Release | [ ] | | Copiar runtime VC++ junto al .exe. |
| 19 | Prueba de portabilidad | [ ] | | |
| 20 | Preparación de distribución | [ ] | | |

## Pendientes abiertos

- **Validar el parser con datos reales.** El 2026-09-30 no se pudo listar `D:\DISCO`: en este
  equipo no existe la unidad D: (solo C: y E:, y E: está vacía). Las reglas de
  `ARQUITECTURA.md` §9 siguen siendo la propuesta inicial. Revisarlas antes o durante las
  fases 6–8, cuando el disco esté conectado.
