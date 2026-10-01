# PRUEBAS — BuscadorTickets

Guía de las pruebas automáticas y manuales (Fase 17). Complementa a `ARQUITECTURA.md` §9.

---

## 1. Cómo ejecutarlas

```
flutter test                      # todas (≈ 40 s)
flutter test --coverage           # + coverage/lcov.info (carpeta ignorada por git)
flutter test test/flujo_completo_test.dart   # solo la prueba de punta a punta
flutter analyze                   # sin advertencias
```

**Reglas que siguen todas las pruebas**
- Usan **carpetas ficticias en un directorio temporal** (`test/helpers/entorno_prueba.dart`), que se
  borran al terminar. **Nunca** tocan el disco real ni escriben en una carpeta raíz de datos.
- El Explorador, el portapapeles y el conteo de elementos se **simulan** en las pruebas de
  pantalla (no se abren ventanas). Sus implementaciones reales tienen pruebas propias.
- El fondo animado es infinito: en pruebas de widget se usan esperas fijas (`pump(duración)`),
  nunca `pumpAndSettle`.
- La E/S real dentro de pruebas de widget va en `tester.runAsync`.

---

## 2. Inventario (183 pruebas, 20 archivos)

| Área | Archivo | Pruebas | Qué cubre |
|---|---|---|---|
| Portabilidad | `core/services/almacenamiento_portable_test.dart` | 10 | `data_usuario` junto al .exe, respaldo, memoria, nunca dentro de una carpeta de año, JSON atómico/corrupto, fallos de lectura/escritura |
| Acciones | `core/services/acciones_sistema_test.dart` | 8 | Abrir carpeta (existe, movida, disco desconectado, error, ruta > 259), comillas con comas, portapapeles real (canal interceptado) |
| Texto | `core/utils/normalizador_test.dart` | 6 | Mayúsculas, tildes, NFD, espacios, palabras |
| Meses | `core/utils/meses_test.dart` | 5 | Nombres, Setiembre, abreviaturas, números, no reconocidos |
| Raíz | `features/search/data/servicio_raiz_test.dart` | 18 | Validación (formato real `2024`, METADA, tildes, padre), resolución (relativa al .exe, absoluta, cambio de letra con mes exigido, varias unidades, UNC), unidades del sistema |
| Años | `features/search/data/detector_anios_test.dart` | 12 | Estructura real, variantes, duplicados, ignoradas, rango, orden |
| Meses | `features/search/data/detector_meses_test.dart` | 8 | 12 meses, orden, ticket sin mes, duplicados, año ilegible |
| Tickets | `features/search/data/detector_tickets_test.dart` | 8 | Número/nombre (separadores, sin número, ceros), estructura real, orden, mes ilegible |
| Índice | `escaner_directorios_test.dart`, `repositorio_indice_test.dart` | 7 | Recorrido en Isolate, avisos, guardar/cargar, dañado, ticket dañado |
| Conteo | `features/search/data/contador_elementos_test.dart` | 3 | Entradas directas, vacía, borrada |
| Motor | `features/search/domain/motor_busqueda_test.dart` | 13 | Ejemplos de la sección 7, prioridad de la sección 8, palabras clave, desempate, filtros, límite, filtrar sin texto |
| Controladores | `buscador_controller_test.dart`, `raiz_controller_test.dart` | 30 | Índice guardado/regenerado, sin conexión, búsqueda y filtros, conteo con caché; selección, propuesta del padre, avisos de configuración |
| Pantalla | `features/search/presentation/pantalla_busqueda_test.dart` | 31 | Los 6 estados en tamaño mínimo (detecta desbordes), foco, avisos, filtros reales (menús), abrir/copiar, elementos, vistas de raíz, sin conexión |
| Modelos | `models/ticket_test.dart`, `models/configuracion_test.dart` | 10 | JSON, campos normalizados, igualdad por ruta, versión |
| Fondo | `widgets/fondo_animado_test.dart` | 3 | Movimiento, pausa sin foco, arranque con ventana inactiva (regresión), animaciones desactivadas |
| App | `widget_test.dart` | 1 | Arranque con foco en la búsqueda |
| **Punta a punta** | `flujo_completo_test.dart` | 1 | Primer uso → elegir carpeta → indexar → buscar → reabrir con índice guardado → disco desconectado → reconectar y actualizar |

---

## 3. Cobertura

**95,5 %** de las líneas de `lib/` (1.337 de 1.400), medido con `flutter test --coverage`.

Lo que queda sin cubrir es, sobre todo:
- **Tiempo límite agotado** (disco que no responde) y **carpetas sin permisos**: requieren
  hardware o permisos de Windows que no se simulan bien en pruebas automáticas ⇒ prueba manual.
- El lanzamiento real de `explorer.exe` (se verificó a mano en la Fase 13) y `main.dart`.
- Textos de avisos que solo aparecen en esos casos.

---

## 4. Casos límite de `ARQUITECTURA.md` §9 → prueba

| Caso | Prueba |
|---|---|
| Formato real `2024`, `2025`, `2026` | `servicio_raiz_test` (validar), `detector_anios_test` (estructura real) |
| Variantes METADA (`Metada 2024`, `METADA_2024`…) | `detector_anios_test`, `servicio_raiz_test` |
| `2024 (copia)`, `METADATA 2025` ignoradas y avisadas | `detector_anios_test`, `escaner_directorios_test` |
| Dos carpetas del mismo año / mes | `detector_anios_test`, `detector_meses_test` |
| Usuario elige `…\2024` o `METADA 2024` ⇒ propone el padre | `servicio_raiz_test`, `raiz_controller_test`, `pantalla_busqueda_test` |
| Carpeta inválida con raíz activa ⇒ se mantiene | `raiz_controller_test` |
| Ruta válida en varias unidades ⇒ elige el usuario | `servicio_raiz_test`, `pantalla_busqueda_test` |
| Cambio de letra (exige un mes reconocido) | `servicio_raiz_test`, `raiz_controller_test` |
| UNC: solo absoluta | `servicio_raiz_test` |
| Variantes de mes, `Semana 1` no es mes, `06 Mayo` | `meses_test` |
| Carpeta del año que no es mes ⇒ no reconocida o ticket sin mes | `detector_meses_test`, `detector_tickets_test` |
| Ticket sin `_`, sin número, solo número, ceros | `detector_tickets_test` |
| Número duplicado en otro mes/año | `detector_tickets_test`, `ticket_test` |
| Tildes, mayúsculas, NFD | `normalizador_test`, `motor_busqueda_test` |
| Carpetas vacías, archivos sueltos | `detector_anios/meses/tickets_test`, `contador_elementos_test` |
| Disco desconectado al abrir ⇒ sin conexión | `buscador_controller_test`, `pantalla_busqueda_test`, `flujo_completo_test` |
| Ticket borrado/movido al abrir ⇒ mensaje | `acciones_sistema_test`, `pantalla_busqueda_test` |
| Índice corrupto o de otra raíz | `repositorio_indice_test`, `buscador_controller_test` |
| Rutas con comas / > 259 caracteres | `acciones_sistema_test` (+ manual Fase 13) |
| Consultas cortas ⇒ límite 200 | `motor_busqueda_test`, `pantalla_busqueda_test` |
| Configuración no escribible ⇒ respaldo/memoria con aviso | `almacenamiento_portable_test`, `raiz_controller_test` |
| `data_usuario` nunca dentro de una carpeta de año | `almacenamiento_portable_test` |
| Disco que no responde, sin permisos | **Manual** (ver §5) |

---

## 5. Verificaciones manuales

**Ya hechas con el disco real (solo lectura), fases 8–16:** detección de años/meses/tickets,
índice guardado y reutilizado, búsquedas de la sección 7, filtros, conteo de elementos, abrir un
ticket real con tildes y `&`, rutas con comas y largas en el Explorador real, CPU en Release.

**Lista para probar a mano** (antes de entregar y en la Fase 19):

1. [ ] Primer uso: elegir la unidad del disco con "SELECCIONAR CARPETA".
2. [ ] Elegir `<unidad>\2024` ⇒ propone la unidad completa.
3. [ ] Buscar `100219`, `curacion`, `E&N`, `ia proyecto`.
4. [ ] Filtros: Año/Mes con texto y sin texto.
5. [ ] ABRIR CARPETA abre el Explorador en el ticket; COPIAR RUTA y pegar en el Bloc de notas.
6. [ ] Cerrar y reabrir: entra directo con el índice guardado.
7. [ ] Desconectar el disco con la app en el PC ⇒ aviso sin conexión y búsqueda en el índice.
8. [ ] Reconectar y "Actualizar índice".
9. [ ] Disco en reposo: la primera validación puede tardar unos segundos ("Verificando…").
10. [ ] Conectar el disco en otro puerto/PC (otra letra) con la app dentro del disco.
11. [ ] Tamaño mínimo de ventana: nada se corta.
12. [ ] Administrador de tareas: CPU baja en reposo y casi 0 sin foco.

---

## 6. Prueba de portabilidad (Fase 19)

Hecha el 2026-10-01 con la carpeta `build\windows\x64\runner\Release\` **copiada** (no ejecutada
en su sitio). El "disco" de prueba es una carpeta temporal con `2024\Mayo` (2 tickets, uno con coma
y `&`), `2025\Enero` (1 ticket) y `2026` vacía. El disco real solo se **leyó** en el escenario 4.

**Copia:** 16 archivos, 28,8 MB; SHA-256 idéntico al original. Sin `data_usuario` al entregar.

| # | Escenario | Resultado |
|---|---|---|
| 1 | App dentro del disco (`<disco>\BuscadorTickets\`), ruta con espacios y `ñ`, primer uso | Pantalla de primer uso, sin errores |
| 2 | Raíz configurada = carpeta padre del .exe (`raizRelativaExe` = `..`) | Indexa 3 tickets; `config.json` e `indice.json` en `data_usuario` junto al .exe |
| 3 | El disco completo se traslada a otra ubicación (otro "PC") | Encuentra la raíz por la ruta relativa, avisa "Se detectó la carpeta raíz…", guarda la nueva ruta y regenera el índice |
| 4 | App en el PC, raíz guardada `Q:\` (ya no existe); disco METADA en `D:` | Cambio de letra: encuentra `D:\` (tiene un mes reconocido), avisa e indexa 3 tickets |
| 5 | Carpeta del programa sin permiso para crear archivos | Aviso "No se puede escribir junto al programa…" y usa `%LOCALAPPDATA%\BuscadorTickets` |

**En todos:** el proceso carga `msvcp140.dll`, `vcruntime140.dll`, `vcruntime140_1.dll` y
`flutter_windows.dll` **desde la carpeta de la app** (comprobado en los módulos del proceso);
~130–145 MB de RAM; la carpeta raíz queda igual (solo las carpetas de año y la de la app).

**Observaciones**
- Con una unidad virtual `subst`, `Platform.resolvedExecutable` devuelve la ruta real (en `C:`), así
  que la raíz se guarda con esa ruta. Funciona igual; con un disco físico se conserva su letra.
  Por eso `subst` no sirve para simular un cambio de letra: se simuló moviendo la carpeta (3) y
  con una letra inexistente (4).
- El aviso de respaldo puede partir la ruta en dos líneas después de `C:` (solo visual).

**No verificable en este equipo:** un PC **sin** el runtime de Visual C++ instalado. La app no
depende de él (carga sus propias copias; `dumpbin` solo muestra DLL del sistema), pero conviene
confirmarlo en otro PC.

**Para el usuario (con el disco real):**
1. Copiar la carpeta `Release` al disco como `<unidad>:\BuscadorTickets\`.
2. Ejecutar `BuscadorTickets.exe` desde el disco, elegir la unidad y buscar `100219`.
3. Expulsar el disco, conectarlo en otro puerto o PC (otra letra) y volver a abrir la app desde el disco: debe entrar directo, sin preguntar.
