# PROGRESO DEL PROYECTO — BuscadorTickets

Leyenda: `[x]` completada · `[ ]` pendiente

| # | Fase | Estado | Fecha | Notas |
|---|------|--------|-------|-------|
| 1 | Análisis del contexto | [x] | 2026-09-30 | Casos límite en `ARQUITECTURA.md` §9. |
| 2 | Arquitectura | [x] | 2026-09-30 | Aprobada y guardada en `docs/ARQUITECTURA.md`. |
| 3 | Configuración Flutter Windows | [x] | 2026-09-30 | `BINARY_NAME` = `BuscadorTickets`; título "Buscador de Tickets"; ventana 1100×750, mínimo 800×600 (`WM_GETMINMAXINFO`, escalado por DPI); metadatos del .exe en `Runner.rc`; `pubspec`: sin `cupertino_icons`, con `file_selector` ^1.1.0 y `path` ^1.9.1; estructura de `lib/` con archivos stub; prueba de arranque. |
| 4 | Interfaz | [x] | 2026-09-30 | Pantalla completa con datos de demostración: encabezado (raíz + botones sin lógica), búsqueda con foco inicial y Enter, filtros Año/Mes, tarjeta, 6 estados, aviso, pie. Tema claro M3 (`AppTheme`), ancho máximo 900 px. `BuscadorController` con estado `sealed`; `Ticket` mínimo; `FiltrosBusqueda`. 10 pruebas de widget a 784×560. |
| 5 | Selección de carpeta raíz | [ ] | | Incluye resolución de raíz para disco USB: relativa al .exe → absoluta → detección de unidades; botón de primer uso (`ARQUITECTURA.md` §7). |
| 6 | Detección de años | [ ] | | Crear aquí el modelo `Ticket` mínimo si hace falta. |
| 7 | Detección de meses | [ ] | | |
| 8 | Detección de tickets | [ ] | | |
| 9 | Modelo de datos | [ ] | | Completar `Ticket` (toJson/fromJson, campos normalizados). |
| 10 | Indexación | [ ] | | |
| 11 | Motor de búsqueda | [ ] | | |
| 12 | Resultados | [ ] | | Conteo de elementos bajo demanda para tarjetas visibles. **Eliminar `datos_demo.dart`** y todo lo marcado `TEMPORAL` (buscar "TEMPORAL" en `lib/`). |
| 13 | Abrir carpeta | [ ] | | Probar rutas largas y con comas. |
| 14 | Copiar ruta | [ ] | | |
| 15 | Filtros | [ ] | | |
| 16 | Optimización | [ ] | | |
| 17 | Pruebas | [ ] | | |
| 18 | Build Release | [ ] | | Copiar runtime VC++ junto al .exe. |
| 19 | Prueba de portabilidad | [ ] | | |
| 20 | Preparación de distribución | [ ] | | |

## Notas técnicas

- Tras renombrar `BINARY_NAME` hubo que ejecutar `flutter clean`: la caché de CMake en `build/`
  seguía apuntando al target `buscador_tickets`. Si otro equipo tiene un `build/` antiguo, hacer lo mismo.

## Pendientes abiertos

- **Validar el parser con datos reales.** El 2026-09-30 no se pudo listar `D:\DISCO`: en este
  equipo no existe la unidad D: (solo C: y E:, y E: está vacía). Las reglas de
  `ARQUITECTURA.md` §9 siguen siendo la propuesta inicial. Revisarlas antes o durante las
  fases 6–8, cuando el disco esté conectado. Los datos están en un **disco externo USB** que
  no estaba conectado; la letra real se verá al conectarlo.
- Mientras no haya disco, las fases 5–8 se prueban con carpetas ficticias creadas en un
  directorio temporal (nunca en datos reales).
