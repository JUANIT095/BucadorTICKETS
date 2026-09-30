# ARQUITECTURA APROBADA — BuscadorTickets

Documento de referencia para las fases 3 en adelante. Complementa a `CONTEXTO_MAESTRO.md`.
Aprobado al cierre de la Fase 2. Cualquier cambio posterior debe anotarse en la sección 10.

---

## 1. Resumen

Capa de búsqueda de **solo lectura** sobre la estructura:

```
RAÍZ (elegida por el usuario)
└── METADA <AAAA>          → año
    └── <Mes>              → mes
        └── <N>_<Nombre>   → TICKET = carpeta (unidad de búsqueda)
            └── archivos   → contenido (fuera del MVP, salvo conteo de elementos)
```

Solo se leen **3 niveles de carpetas**; nunca se entra al contenido de un ticket durante la indexación.

---

## 2. Estructura de `lib/`

```
lib/
├── main.dart                        Arranque: carga config/índice y lanza la app
├── app.dart                         MaterialApp + tema
├── core/
│   ├── constants/
│   │   ├── textos.dart              Textos de UI y mensajes de error centralizados
│   │   └── app_constants.dart       Nombres de archivos JSON, límite de resultados, versión del índice
│   ├── theme/app_theme.dart         Tema visual
│   ├── utils/
│   │   ├── normalizador.dart        Minúsculas + quitar tildes + tokenizar
│   │   ├── meses.dart               Nombres/abreviaturas de meses, parseo a 1–12
│   │   └── mensajes_error.dart      Traduce FileSystemException a mensaje amigable
│   └── services/
│       ├── almacenamiento_portable.dart  Ubica data_usuario/, prueba escritura, respaldo,
│       │                                 lectura/escritura atómica de JSON
│       └── acciones_sistema.dart    Abrir en Explorador, copiar al portapapeles
├── models/
│   ├── ticket.dart                  Modelo Ticket (+ toJson/fromJson)
│   ├── indice.dart                  Metadatos del índice + lista de tickets
│   ├── configuracion.dart           Carpeta raíz elegida
│   └── carpeta_anio.dart            Carpeta de año: año, nombre y ruta (Fase 6)
├── features/search/
│   ├── data/
│   │   ├── servicio_raiz.dart       Validación y resolución de la carpeta raíz (Fase 5)
│   │   ├── detector_anios.dart      Carpetas de año en el primer nivel de la raíz (Fase 6)
│   │   ├── parser_carpetas.dart     Reconoce carpetas de año, mes y ticket (funciones puras)
│   │   ├── escaner_directorios.dart Recorrido del disco (función ejecutada en Isolate)
│   │   └── repositorio_indice.dart  Cargar/guardar/regenerar el índice
│   ├── domain/
│   │   ├── filtros_busqueda.dart    Año/mes seleccionados
│   │   └── motor_busqueda.dart      Filtrado + puntuación + orden
│   └── presentation/
│       ├── buscador_controller.dart ChangeNotifier con el estado de la búsqueda
│       ├── raiz_controller.dart     ChangeNotifier con el estado de la carpeta raíz (Fase 5)
│       ├── pantalla_busqueda.dart   Pantalla principal
│       └── widgets/                 barra_busqueda, panel_filtros, tarjeta_ticket, vista_estado,
│                                    vista_raiz
└── widgets/
    ├── banner_aviso.dart            Aviso reutilizable (raíz no disponible, respaldo en uso…)
    ├── fondo_animado.dart           Fondo negro con brillos rojos animados
    └── panel_vidrio.dart            Panel de vidrio esmerilado
```

`test/` replica la estructura: normalizador, parser, motor de búsqueda y escáner. El escáner se
prueba con carpetas ficticias creadas en un directorio temporal; **nunca** contra datos reales.

El modelo `Ticket` se crea en forma mínima en cuanto lo necesite una fase de detección (6–8) y se
completa en la Fase 9.

---

## 3. Modelo de datos

```dart
class Ticket {
  final String? numero;        // "100219" (texto, conserva ceros); null si no tiene
  final String nombre;         // "Curación2 ABC - Proyecto IA"
  final String nombreCarpeta;  // "100219_Curación2 ABC - Proyecto IA"
  final int anio;              // 2024
  final int? mes;              // 5; null si la carpeta de mes no se reconoce
  final String carpetaMes;     // "Mayo" (nombre original, para mostrar)
  final String rutaRelativa;   // "METADA 2024\Mayo\100219_Curación2 ABC - Proyecto IA"

  // Solo en memoria (no se persisten), calculados al cargar:
  // numeroNorm, nombreNorm, carpetaNorm, palabras
}
```

- Ruta absoluta = `raíz + rutaRelativa` (sobrevive a cambios de letra de unidad).
- La clave única es la ruta, no el número (puede haber números duplicados).
- El conteo de elementos **no** forma parte del modelo persistido.

---

## 4. Indexación

**Recorrido:** raíz → carpetas METADA → meses → tickets. `listSync(followLinks: false)`, con un
`try/catch` por carpeta: un error omite esa carpeta, se cuenta y la indexación continúa.

**Isolate:** `Isolate.run(() => escanear(raiz))` devuelve la lista de tickets + número de carpetas
omitidas. El `jsonDecode` de un índice grande también se hace en Isolate. La UI muestra
"Indexando…" con indicador indeterminado (progreso real con `Isolate.spawn` + `SendPort` queda
para la Fase 16 si se necesita).

**Archivos** (en la carpeta de datos, ver sección 6):

`indice.json`
```json
{ "version": 1, "raiz": "D:\\DISCO", "generado": "2026-09-30T10:15:00",
  "carpetasOmitidas": 0,
  "tickets": [ { "numero": "100219", "nombre": "…", "anio": 2024, "mes": 5,
                 "carpetaMes": "Mayo", "ruta": "METADA 2024\\Mayo\\100219_…" } ] }
```

`config.json`
```json
{ "version": 1, "raiz": "D:\\DISCO" }
```

Separados para poder borrar el índice sin perder la configuración. Escritura atómica: se escribe
`*.tmp` y se renombra, siempre dentro de la carpeta de datos, **nunca** dentro de la raíz.

**Actualización:**
- Botón "Actualizar índice" = recorrido completo (≈40 listados de carpeta; lo incremental no aporta).
- Al arrancar se carga el índice guardado → búsqueda inmediata.
- Si no hay índice, la versión no coincide o la raíz guardada difiere → se reindexa automáticamente.
- Se muestra "Índice actualizado: <fecha hora>".

**Conteo de elementos (aprobado):** bajo demanda, solo para las tarjetas visibles: `list()`
asíncrono de la carpeta del ticket (entradas directas), cacheado en memoria durante la sesión.

---

## 5. Búsqueda y ranking

**Normalización** (`normalizador.dart`), aplicada igual a consulta y tickets:
1. `toLowerCase()`.
2. á é í ó ú ü ñ (y mayúsculas) → letra base.
3. Eliminar diacríticos combinantes U+0300–U+036F (nombres en forma NFD).
4. Recortar espacios.
5. Tokens: separar por espacio, `_`, `-`, `–`.

**Algoritmo:** aplicar filtros de año/mes → calcular la mayor puntuación de cada ticket:

| Pts  | Regla (q = consulta normalizada) |
|------|----------------------------------|
| 1000 | `numero == q` o nombre de carpeta completo `== q` |
| 900  | número empieza por `q` |
| 800  | número contiene `q` |
| 700  | nombre (o nombre de carpeta) empieza por `q` |
| 500  | nombre contiene `q` |
| 300  | **TODAS** las palabras de la consulta aparecen en el ticket, en cualquier orden (aprobado) |
| —    | sin coincidencia → descartado |

- Desempate: año desc → mes desc → número asc.
- Máximo 200 resultados mostrados, con aviso "mostrando 200 de N".
- Búsqueda en el hilo principal (textos pre-normalizados); pasar a `compute` solo si se mide lentitud.
- Se dispara con el botón BUSCAR o Enter.

---

## 6. Gestión de estado

- Un `BuscadorController extends ChangeNotifier` + `ListenableBuilder`. Sin paquetes.
- Estado como clase `sealed`: `Inicial`, `Indexando`, `Buscando`, `ConResultados`,
  `SinResultados`, `Error`, más avisos no bloqueantes (raíz no disponible, respaldo en uso,
  carpetas omitidas).
- Dependencias (repositorio, motor) inyectadas por constructor para facilitar pruebas.

---

## 7. Portabilidad

**Carpeta de datos:**
1. Principal: `<carpeta del .exe>\data_usuario\` (vía `Platform.resolvedExecutable`).
   No se usa `data\` porque es de Flutter.
2. Al arrancar se prueba escritura (crear/borrar un archivo de prueba en `data_usuario\`).
3. **Respaldo (aprobado):** si falla → `%LOCALAPPDATA%\BuscadorTickets\` con **aviso visible
   permanente**.
4. Si el respaldo también falla → modo solo memoria, avisando que el índice no se guardará.

**Regla de escritura (precisada en la Fase 5):** la app solo escribe en su carpeta de datos
(`<carpeta del .exe>\data_usuario\` o el respaldo). Nunca escribe en una carpeta METADA ni
directamente en la raíz. Si `data_usuario\` quedara dentro de una carpeta METADA, se usa el
respaldo. Recomendación: ubicar la app fuera de la carpeta de datos (p. ej. `E:\BuscadorTickets\`
junto a `E:\DISCO\`).

**Escenario real (confirmado):** las carpetas METADA están en un **disco externo USB** y la app
se distribuye **dentro de ese mismo disco**. La raíz suele ser la unidad completa (p. ej. `E:\`)
y la letra puede cambiar según el PC o el puerto. Por eso `data_usuario\` (config + índice) viaja
con el disco.

**Resolución de la carpeta raíz al arrancar** (Fase 5), en este orden:
1. **Relativa al .exe:** si la raíz está en la misma unidad que el .exe, `config.json` guarda
   también `raizRelativaExe` (p. ej. `..` o `..\..`). Si esa ruta existe, se usa; funciona con
   cualquier letra de unidad.
2. **Absoluta:** `raiz` guardada en `config.json`, si existe.
3. **Cambio de letra:** si ninguna existe, se prueba la ruta guardada con otra letra de unidad
   (`E:\DISCO` → `F:\DISCO`, …), de `C:` a `Z:` (se omiten A: y B:), en paralelo y con tiempo
   límite por unidad. Exactamente una coincidencia válida → se usa, se actualiza `config.json` y se
   avisa ("Se detectó la carpeta en F:\DISCO"). Varias → no se elige: se pide al usuario que elija.
   Ninguna → "raíz no encontrada". Las rutas UNC (`\\servidor\…`) solo se prueban como absolutas.
4. Sin raíz resuelta → estado "raíz no encontrada" (REINTENTAR / ELEGIR OTRA CARPETA) y búsqueda
   deshabilitada. En la Fase 10, si hay índice guardado, se permitirá buscar en él con aviso de
   raíz no disponible.

Toda operación de disco de la resolución y la validación es asíncrona y con tiempo límite.

**Primer uso:** sin configuración, el área central muestra "Selecciona la carpeta donde están
las carpetas METADA" y el botón SELECCIONAR CARPETA; la búsqueda queda deshabilitada. El selector
permite elegir una unidad completa.

**Estado de la raíz:** `RaizController` (separado de `BuscadorController`) con estado `sealed`:
verificando, sin configurar, activa, no encontrada, inválida y propuesta de carpeta padre.

`config.json` pasa a ser:
```json
{ "version": 1, "raiz": "E:\\DISCO", "raizRelativaExe": "..\\DISCO" }
```
(`raizRelativaExe` se omite si la raíz está en otra unidad que el .exe.)

**Distribución** (`build\windows\x64\runner\Release\`, se entrega completa):
- `BuscadorTickets.exe`
- `flutter_windows.dll`
- `file_selector_windows_plugin.dll`
- `data\` → `icudtl.dat`, `app.so`, `flutter_assets\`
- Runtime VC++: `msvcp140.dll`, `vcruntime140.dll`, `vcruntime140_1.dll` (Flutter **no** los
  incluye; se copian junto al .exe — despliegue app-local — automatizable en el `install` de CMake
  en las fases 18–20).

**Pendiente Fase 3:** `BINARY_NAME` en `windows/CMakeLists.txt` es hoy `"buscador_tickets"` →
cambiar a `BuscadorTickets`.

---

## 8. Dependencias (aprobadas)

| Paquete / recurso | Decisión | Justificación |
|---|---|---|
| `file_selector` | Agregar (Fase 3/5) | No hay selector de carpeta nativo en Dart/Flutter. Oficial del equipo Flutter; usa el diálogo de Windows. |
| `path` | Agregar (Fase 3) | Oficial de Dart, ya transitiva de Flutter (sin peso extra). Unión de rutas segura con UNC/red. |
| `cupertino_icons` | **Quitar** (Fase 3) | No se usa en Windows. |
| Abrir carpeta | Sin paquete | `Process.start('explorer.exe', [ruta])`. `explorer.exe` devuelve 1 aun con éxito: validar existencia antes, no el código de salida. |
| Portapapeles | Sin paquete | `Clipboard.setData` (`flutter/services`). |
| Ruta del .exe, JSON, Isolates | Sin paquete | `dart:io`, `dart:convert`, `dart:isolate`. |
| Estado | Sin paquete | `ChangeNotifier`. |
| Pruebas | Sin paquete | `flutter_test` + `flutter_lints` (ya presentes). |

---

## 9. Casos límite y manejo

> **Pendiente de validar con datos reales:** las reglas del parser se ajustarán cuando haya acceso
> a la carpeta raíz real (ver `PROGRESO.md`).

| Caso | Manejo |
|---|---|
| Ticket sin `_` (`100219 - Nombre`, `100219-Nombre`, `100219 Nombre`) | Número = dígitos iniciales; separador `_`, `-`, `–` o espacio; se corta solo en el primer separador (`100219_ABC_v2` → nombre `ABC_v2`). |
| Carpeta sin número (`Varios`) | Se indexa con `numero = null`, nombre = nombre completo; tarjeta muestra "Sin número". |
| Solo número (`100219`) | Nombre vacío; la tarjeta muestra el nombre de carpeta. |
| Número duplicado en otro mes/año | Se muestran todos; clave = ruta. |
| Ceros a la izquierda (`000123`) | Número como texto; `123` lo encuentra por coincidencia parcial. |
| Variantes de año (`Metada 2024`, `METADA_2024`, `METADA-2024`, `METADA2024`) | Aceptadas: `metada` + espacios, `_` o `-` opcionales + 4 dígitos, sin distinguir mayúsculas. Años aceptados 2000–2100, detectados dinámicamente (2027+ aparece solo en el filtro). |
| `METADATA 2024`, `METADA 2024 (copia)` u otro nombre que contiene "metada" sin cumplir el patrón | Se ignora pero **se registra** y se avisa al usuario ("nombre no reconocido"). Un año fuera de 2000–2100 se registra como "año fuera de rango". Las carpetas que no se parecen a METADA no se registran. |
| Dos carpetas del mismo año (`METADA 2024` y `metada_2024`) | Se conservan **todas** (no se pierde ningún ticket) y se avisa del duplicado. El filtro muestra el año una sola vez. |
| Usuario elige `METADA 2024` como raíz | Se **propone** su carpeta padre y se espera confirmación (no se cambia sola). Si no hay METADA: mensaje "Esta carpeta no contiene carpetas METADA". |
| Se elige una carpeta inválida teniendo ya una raíz activa | Se mantiene la raíz actual y el motivo se muestra como aviso. |
| La ruta guardada es válida en varias unidades | No se elige automáticamente; se pide al usuario que elija. |
| Variantes de mes (tildes, mayúsculas, `Setiembre`, `Ene`/`Sep`/`Set`, `05`, `5`, `05 Mayo`, `05-Mayo`, `Mayo 2024`) | Normalizar → buscar nombre/abreviatura de mes → si no, número suelto 1–12. Filtro por número de mes; tarjeta muestra nombre original. |
| Carpeta dentro del año que no es mes | 1) ¿Mes? → mes. 2) ¿Parece ticket (≥4 dígitos + separador)? → ticket directo del año, `mes = null`. 3) Si no → "mes desconocido", se indexan sus tickets con el nombre original. Visibles con Mes = "Todos". |
| Tildes / mayúsculas | Normalización de la sección 5 (incluye NFD). |
| Carpetas vacías (año, mes, ticket) | No es error; ticket vacío = "0 elementos". |
| Archivos sueltos en carpetas de mes (`Thumbs.db`, `desktop.ini`, PDFs) | Ignorados; solo cuentan directorios. |
| Carpetas de sistema (`$RECYCLE.BIN`, `System Volume Information`) | Ignoradas (en la raíz solo se consideran METADA). |
| Accesos directos, symlinks, junctions | No se siguen (`followLinks: false`). |
| Rutas de red (UNC, unidades mapeadas) | Funcionan con `dart:io`; lentitud aislada en Isolate. Unidades mapeadas no visibles si la app corre como administrador. |
| Disco/red desconectado al abrir | Se usa el índice guardado con aviso "La carpeta raíz no está disponible; resultados del último índice". Abrir muestra error claro. |
| Carpeta sin permisos | Se omite, se cuenta y se informa "N carpetas no se pudieron leer". |
| Ticket borrado/renombrado tras indexar | Verificar existencia antes de abrir: "Este ticket ya no está en esa ubicación. Pulsa Actualizar índice." |
| Cambio de letra de unidad | Rutas relativas a la raíz en el índice + resolución de la raíz relativa al .exe y detección automática de unidades (§7). |
| Raíz = unidad completa (`E:\`) | Válido; `System Volume Information` y `$RECYCLE.BIN` se ignoran. |
| Índice corrupto o de otra raíz | Se descarta, se reindexa y se avisa. |
| Rutas > 260 caracteres o con comas | Riesgo en `explorer.exe`; se prueba explícitamente en la Fase 13. |
| Consultas muy cortas (`1`, `a`) | Límite de 200 resultados + aviso "mostrando 200 de N". |

---

## 10. Registro de cambios de arquitectura

| Fecha | Fase | Cambio |
|---|---|---|
| 2026-09-30 | 2 | Versión inicial aprobada. |
| 2026-09-30 | 4→5 | Disco externo USB con la app dentro: raíz relativa al .exe, detección automática de unidades y botón de primer uso (§7). `config.json` agrega `raizRelativaExe`. |
| 2026-09-30 | 4 | Tema único negro/blanco/rojo con vidrio difuminado y animaciones; nuevos `widgets/fondo_animado.dart` y `widgets/panel_vidrio.dart`. |
| 2026-09-30 | 5 | Detección por cambio de letra de la ruta guardada (C:–Z:), ambigüedad → elige el usuario; propuesta del padre con confirmación; regla de escritura precisada; `RaizController` separado, `servicio_raiz.dart` y `vista_raiz.dart`. La configuración la manejan `AlmacenamientoPortable` + `Configuracion` (`repositorio_indice.dart` queda para el índice). |
| 2026-09-30 | 6 | `DetectorAnios` + `CarpetaAnio`; reglas de variantes, duplicados y carpetas ignoradas (§9). Los años los guarda `BuscadorController` y la detección se lanza desde `app.dart` al cambiar la raíz activa. |
