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
| 10 | Indexación | [x] | 2026-10-01 | Validada por el usuario (commit `359e139`). `escaner_directorios.dart` (`escanearRaiz` en `Isolate.run`, reúne tickets y avisos); `models/indice.dart`; `repositorio_indice.dart` (`indice.json` en `data_usuario`, JSON en Isolate, dañado ⇒ se regenera con aviso); `AlmacenamientoPortable.leerTexto/escribirTexto`. Controlador: índice guardado al arrancar si es de la misma raíz, si no indexa; "Actualizar índice" conectado; modo sin conexión con el último índice. Ya no usa los tickets de demostración (solo el selector debug). **Verificado con el disco real:** genera `indice.json` con los 3 tickets y en el segundo arranque lo reutiliza sin recorrer. 120 pruebas (18 nuevas). |
| 11 | Motor de búsqueda | [x] | 2026-10-01 | Validada por el usuario (commit `15613f8`). `motor_busqueda.dart` (puntuación §5/§8, filtros, desempate, límite 200 con total); `BuscadorController.buscar` usa el motor (se elimina la búsqueda TEMPORAL que mostraba todo); cabecera "Mostrando 200 de N". **Verificado con el disco real:** los ejemplos de la sección 7 (100219, Curación2, CURACION2, Proyecto IA, nombre completo) devuelven 100219; "E&N" → 100222 y 100226. Rendimiento: 20.000 tickets en 11–18 ms (peor caso ~130 ms, a revisar en la Fase 16). 142 pruebas (22 nuevas). |
| 12 | Resultados | [x] | 2026-10-01 | Validada por el usuario (commit `304d5b4`). Conteo real de elementos bajo demanda solo para tarjetas construidas (visibles), con caché por sesión y "No disponible" si la carpeta no se puede leer. Eliminados `datos_demo.dart`, el botón debug y todo lo TEMPORAL (ya no queda ninguno en `lib/`). **Verificado con el disco real:** buscar "1002" muestra los 3 tickets con 1, 2 y 0 elementos y la ruta `D:\2024\Mayo\…`. 150 pruebas (8 nuevas). |
| 13 | Abrir carpeta | [x] | 2026-10-01 | Validada por el usuario (commit `d4ef80f`). `AccionesSistema.abrirCarpeta` (existencia previa, ticket movido vs. disco desconectado, `explorer.exe` desacoplado con comillas forzadas, rutas > 259 ⇒ carpeta más cercana); botón ABRIR CARPETA conectado; mensajes breves en SnackBar. **Comprobado con el Explorador real:** comas (sin comillas abría "Documentos"), tildes y `&`, ruta de 361 caracteres; y un ticket real del disco. 162 pruebas (12 nuevas). |
| 14 | Copiar ruta | [x] | 2026-10-01 | Validada por el usuario (commit `ce1598d`). `copiarAlPortapapeles` + `BuscadorController.copiarRuta`; botón COPIAR RUTA conectado con confirmación "Ruta copiada: …" y mensaje de error claro. Prueba con el canal real de Flutter interceptado: envía la ruta exacta (tildes y `&`). Ya no queda ningún botón sin lógica. 165 pruebas (3 nuevas). |
| 15 | Filtros | [x] | 2026-10-01 | Validada por el usuario (commit `7c627be`). Cambiar un filtro vuelve a buscar; filtro sin texto lista los tickets de ese año/mes; "sin resultados" con filtros sugiere cambiarlos; `FiltrosBusqueda.activos`; `MotorBusqueda.filtrar`. **Verificado con el disco real:** 2024 + Mayo sin texto ⇒ 3 tickets; "E&N" + 2025 ⇒ sin resultados (con filtros); "E&N" + Todos ⇒ 2. 171 pruebas (6 nuevas). |
| 16 | Optimización | [x] | 2026-10-01 | Pendiente de validación del usuario. Medido con 20.000 tickets y en Release. **Normalizador** 5,7× más rápido (carga del índice 567 → 256 ms). **Desempate** con clave precalculada: peor búsqueda 215 → 19,5 ms (no hace falta `compute`). Recorrido de 19.800 tickets: 628 ms. **Fondo animado** a ~10 cuadros/s y en pausa sin foco: CPU en reposo con foco 33–50 % → 3–9 % de un núcleo, sin foco 0–1 %. Encontrado y corregido: detener la animación antes del primer cuadro hacía que la app se cerrara al arrancar (prueba de regresión). 174 pruebas (3 nuevas). |
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
- Desde la Fase 10 el pie muestra la fecha y el total reales del índice. Desde la Fase 11 la
  búsqueda usa el motor real (§5); desde la Fase 15 los filtros vuelven a buscar al cambiar y, sin texto, listan los tickets del año/mes.
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
