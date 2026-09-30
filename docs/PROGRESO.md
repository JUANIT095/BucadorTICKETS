# PROGRESO DEL PROYECTO — BuscadorTickets

Leyenda: `[x]` completada · `[ ]` pendiente

| # | Fase | Estado | Fecha | Notas |
|---|------|--------|-------|-------|
| 1 | Análisis del contexto | [x] | 2026-09-30 | Casos límite en `ARQUITECTURA.md` §9. |
| 2 | Arquitectura | [x] | 2026-09-30 | Aprobada y guardada en `docs/ARQUITECTURA.md`. |
| 3 | Configuración Flutter Windows | [x] | 2026-09-30 | `BINARY_NAME` = `BuscadorTickets`; título "Buscador de Tickets"; ventana 1100×750, mínimo 800×600 (`WM_GETMINMAXINFO`, escalado por DPI); metadatos del .exe en `Runner.rc`; `pubspec`: sin `cupertino_icons`, con `file_selector` ^1.1.0 y `path` ^1.9.1; estructura de `lib/` con archivos stub; prueba de arranque. |
| 4 | Interfaz | [x] | 2026-09-30 | Pantalla completa con datos de demostración: encabezado (raíz + botones sin lógica), búsqueda con foco inicial y Enter, filtros Año/Mes, tarjeta, 6 estados, aviso, pie. Tema claro M3 (`AppTheme`), ancho máximo 900 px. `BuscadorController` con estado `sealed`; `Ticket` mínimo; `FiltrosBusqueda`. 10 pruebas de widget a 784×560. **Ajuste visual (aprobado):** reemplaza el tema claro por un tema único negro/blanco/rojo (`AppTheme.oscuro`) con fondo animado de brillos rojos difuminados (`FondoAnimado`), paneles de vidrio esmerilado (`PanelVidrio`) en encabezado, búsqueda, pie y avisos, transición entre estados, entrada escalonada de tarjetas, hover rojo en tarjetas, brillo del campo con foco y botón BUSCAR con degradado. Las tarjetas no usan desenfoque real (rendimiento). El fondo queda fijo si Windows tiene desactivadas las animaciones. |
| 5 | Selección de carpeta raíz | [x] | 2026-09-30 | Validada por el usuario (commit `2d3cbcb`). `AppConstants.patronMetada`; `AlmacenamientoPortable` (data_usuario → `%LOCALAPPDATA%` → memoria, JSON UTF-8 atómico, nunca dentro de METADA); `Configuracion` (versión 1, JSON inválido = sin configuración); `ServicioRaiz` (validación tipada con tiempo límite; resolución relativa al .exe → absoluta → cambio de letra C:–Z:, UNC solo absoluta, ambigüedad → elige el usuario); `RaizController` separado con estado `sealed`; `VistaRaiz` (primer uso, no encontrada, inválida, propuesta del padre); búsqueda y filtros deshabilitados sin raíz; "Cambiar carpeta" con `getDirectoryPath`. 46 pruebas (36 nuevas) con carpetas ficticias. |
| 6 | Detección de años | [x] | 2026-09-30 | Pendiente de validación del usuario. `CarpetaAnio`; `parser_carpetas.dart` (`anioDeCarpeta`, rango 2000–2100); `DetectorAnios` (solo primer nivel, solo directorios, asíncrono con tiempo límite, errores por entrada sin cortar el listado, resultado tipado). Reglas: separadores `_`/`-`/espacio aceptados; `METADATA`/"(copia)" ignoradas y registradas; duplicados del mismo año se conservan todos con aviso. Filtro Año con los años reales (vuelve a "Todos" si desaparece). Sin Isolate (un solo listado). 59 pruebas (13 nuevas). Con carpetas ficticias: disco USB no conectado. |
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

- En `flutter run` el .exe está en `build\windows\x64\runner\Debug\`, así que la configuración de
  desarrollo queda en `build\windows\x64\runner\Debug\data_usuario\config.json` (se borra con
  `flutter clean`).
- Tiempo límite de disco: si una unidad se cuelga, la app deja de esperarla (5 s al validar,
  1,5 s por unidad), pero la operación de Windows sigue ocupando un hilo interno hasta responder.
  La UI no se congela.
- El pie sigue mostrando fecha y total de los datos de demostración aunque no haya raíz
  (TEMPORAL hasta la Fase 10/12).

## Pendientes abiertos

- **Validar las fases 5 y 6 con el disco USB real:** nombres reales de las carpetas de primer nivel frente a las reglas de §9 (variantes, duplicados, "(copia)"); además, en la Fase 5: resolución relativa al .exe (app dentro del USB),
  cambio de letra al conectarlo en otro puerto/PC y el tiempo de detección de unidades.

- **Validar el parser con datos reales.** El 2026-09-30 no se pudo listar `D:\DISCO`: en este
  equipo no existe la unidad D: (solo C: y E:, y E: está vacía). Las reglas de
  `ARQUITECTURA.md` §9 siguen siendo la propuesta inicial. Revisarlas antes o durante las
  fases 6–8, cuando el disco esté conectado. Los datos están en un **disco externo USB** que
  no estaba conectado; la letra real se verá al conectarlo.
- Mientras no haya disco, las fases 5–8 se prueban con carpetas ficticias creadas en un
  directorio temporal (nunca en datos reales).
