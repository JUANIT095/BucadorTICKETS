# PROGRESO DEL PROYECTO — BuscadorTickets

Leyenda: `[x]` completada · `[ ]` pendiente

| # | Fase | Estado | Fecha | Notas |
|---|------|--------|-------|-------|
| 1 | Análisis del contexto | [x] | 2026-09-30 | Casos límite en `ARQUITECTURA.md` §9. |
| 2 | Arquitectura | [x] | 2026-09-30 | Aprobada y guardada en `docs/ARQUITECTURA.md`. |
| 3 | Configuración Flutter Windows | [x] | 2026-09-30 | `BINARY_NAME` = `BuscadorTickets`; título "Buscador de Tickets"; ventana 1100×750, mínimo 800×600 (`WM_GETMINMAXINFO`, escalado por DPI); metadatos del .exe en `Runner.rc`; `pubspec`: sin `cupertino_icons`, con `file_selector` ^1.1.0 y `path` ^1.9.1; estructura de `lib/` con archivos stub; prueba de arranque. |
| 4 | Interfaz | [x] | 2026-09-30 | Pantalla completa con datos de demostración: encabezado (raíz + botones sin lógica), búsqueda con foco inicial y Enter, filtros Año/Mes, tarjeta, 6 estados, aviso, pie. Tema claro M3 (`AppTheme`), ancho máximo 900 px. `BuscadorController` con estado `sealed`; `Ticket` mínimo; `FiltrosBusqueda`. 10 pruebas de widget a 784×560. **Ajuste visual (aprobado):** reemplaza el tema claro por un tema único negro/blanco/rojo (`AppTheme.oscuro`) con fondo animado de brillos rojos difuminados (`FondoAnimado`), paneles de vidrio esmerilado (`PanelVidrio`) en encabezado, búsqueda, pie y avisos, transición entre estados, entrada escalonada de tarjetas, hover rojo en tarjetas, brillo del campo con foco y botón BUSCAR con degradado. Las tarjetas no usan desenfoque real (rendimiento). El fondo queda fijo si Windows tiene desactivadas las animaciones. |
| 5 | Selección de carpeta raíz | [x] | 2026-09-30 | Validada por el usuario (commit `2d3cbcb`). `AppConstants.patronMetada`; `AlmacenamientoPortable` (data_usuario → `%LOCALAPPDATA%` → memoria, JSON UTF-8 atómico, nunca dentro de METADA); `Configuracion` (versión 1, JSON inválido = sin configuración); `ServicioRaiz` (validación tipada con tiempo límite; resolución relativa al .exe → absoluta → cambio de letra C:–Z:, UNC solo absoluta, ambigüedad → elige el usuario); `RaizController` separado con estado `sealed`; `VistaRaiz` (primer uso, no encontrada, inválida, propuesta del padre); búsqueda y filtros deshabilitados sin raíz; "Cambiar carpeta" con `getDirectoryPath`. 46 pruebas (36 nuevas) con carpetas ficticias. |
| 6 | Detección de años | [x] | 2026-09-30 | Validada por el usuario (commit `7eef42a`). `CarpetaAnio`; `parser_carpetas.dart` (`anioDeCarpeta`, rango 2000–2100); `DetectorAnios` (solo primer nivel, solo directorios, asíncrono con tiempo límite, errores por entrada sin cortar el listado, resultado tipado). Reglas: separadores `_`/`-`/espacio aceptados; `METADATA`/"(copia)" ignoradas y registradas; duplicados del mismo año se conservan todos con aviso. Filtro Año con los años reales (vuelve a "Todos" si desaparece). Sin Isolate (un solo listado). 59 pruebas (13 nuevas). Con carpetas ficticias: disco USB no conectado. |
| 7 | Detección de meses | [x] | 2026-09-30 | Validada por el usuario (commit `32c17c1`). `CarpetaMes`; `core/utils/meses.dart` (`mesDeCarpeta`: nombres, Setiembre, abreviaturas, prefijos, "05 Mayo", "Mayo 2024", número solo estricto); `pareceTicket`; `DetectorMeses` (un listado por año en paralelo, tiempo límite por año, año ilegible no corta el resto). Reglas §9: mes → ticket sin mes (registrado para la Fase 8) → carpeta no reconocida (sus tickets se incluirán). Duplicados se conservan con aviso. `detectarEstructura` = años + meses. Corregido: el error de listar la propia carpeta (Windows lo reporta como "carpeta*") ya no se cuenta como entrada suelta; aplica también a la detección de años. 74 pruebas (15 nuevas). |
| 8 | Detección de tickets | [x] | 2026-10-01 | Validada por el usuario (commit `e48a183`). **Ajuste previo por el disco real** (aprobado): carpetas de año `2024` además de METADA, cambio de letra exige un mes reconocido, tiempos límite 15 s / 10 s. Fase 8: `numeroYNombreDeTicket` (separadores `_`, `-`, `–`, espacio; corta en el primero; sin número ⇒ nombre = carpeta); `DetectorTickets` (un listado por mes en paralelo, mes ilegible no corta el resto, tickets sueltos en el año ⇒ sin mes); "Sin mes" en la tarjeta. Búsqueda provisional y pie con los tickets detectados (TEMPORAL hasta la Fase 10). **Verificado en el disco real (solo lectura):** años 2024–2026, `2024/Mayo`, 3 tickets correctos. 89 pruebas (15 nuevas). |
| 9 | Modelo de datos | [x] | 2026-10-01 | Validada por el usuario (commit `8244172`). `normalizador.dart` (minúsculas, sin tildes ni diacríticos combinantes NFD, espacios colapsados; `palabrasNormalizadas` por espacio, `_`, `-`, `–`). `Ticket`: JSON del índice (entradas dañadas ⇒ null), campos normalizados en memoria, `rutaEn(raiz)`, igualdad por ruta. 102 pruebas (13 nuevas). |
| 10 | Indexación | [x] | 2026-10-01 | Pendiente de validación del usuario. `escaner_directorios.dart` (`escanearRaiz` en `Isolate.run`, reúne tickets y avisos); `models/indice.dart`; `repositorio_indice.dart` (`indice.json` en `data_usuario`, JSON en Isolate, dañado ⇒ se regenera con aviso); `AlmacenamientoPortable.leerTexto/escribirTexto`. Controlador: índice guardado al arrancar si es de la misma raíz, si no indexa; "Actualizar índice" conectado; modo sin conexión con el último índice. Ya no usa los tickets de demostración (solo el selector debug). **Verificado con el disco real:** genera `indice.json` con los 3 tickets y en el segundo arranque lo reutiliza sin recorrer. 120 pruebas (18 nuevas). |
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
- Tiempo límite de disco: si una unidad se cuelga, la app deja de esperarla (15 s al validar o
  detectar, 10 s por unidad), pero la operación de Windows sigue ocupando un hilo interno hasta
  responder. La UI no se congela.
- Un disco USB en reposo tarda más de 5 s en despertar (medido con el disco real: 6,1 s el primer
  recorrido); por eso los tiempos límite pasaron de 5 s / 1,5 s a 15 s / 10 s.
- Desde la Fase 10 el pie muestra la fecha y el total reales del índice. La búsqueda sigue siendo
  provisional (muestra todos los tickets del índice) hasta la Fase 11.
- El índice de desarrollo queda en `build\windows\x64\runner\Debug\data_usuario\indice.json`.
  Para forzar una indexación desde cero basta con borrarlo (o pulsar "Actualizar índice").
- Si la raíz cambia de letra (D: → F:), la raíz guardada en el índice ya no coincide y se
  regenera automáticamente al arrancar (un recorrido de pocos segundos).

## Pendientes abiertos

- **Disco real revisado el 2026-10-01 (solo lectura):** unidad "METADA" (D: en este equipo) con
  `2024\Mayo` (3 tickets) y `2025`, `2026` vacías. Se ajustaron las reglas de año (número solo).
  Quedan por validar en uso real: la app copiada dentro del disco (`<unidad>\BuscadorTickets\`,
  resolución relativa `..`) y el cambio de letra al conectarlo en otro puerto/PC. Revisar las
  reglas de meses y tickets cuando el disco tenga más datos.
- Las pruebas automáticas siguen usando carpetas ficticias en un directorio temporal; el disco
  real solo se lee en verificaciones manuales puntuales.
