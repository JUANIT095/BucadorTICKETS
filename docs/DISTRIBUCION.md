# DISTRIBUCIÓN — BuscadorTickets

Cómo preparar y entregar la versión portable (Fase 20).

---

## 1. Generar el paquete

```
powershell -ExecutionPolicy Bypass -File scripts\empaquetar.ps1
```

El script:
1. Ejecuta `flutter build windows --release` (omitible con `-SinCompilar`).
2. Comprueba que estén todos los archivos necesarios (si falta alguno, se detiene).
3. Copia la carpeta Release a `dist\BuscadorTickets\` **sin** `data_usuario` (configuración local).
4. Crea `dist\BuscadorTickets-<versión>-windows-x64.zip` y `….zip.sha256`.

`dist/` está en `.gitignore`: los paquetes no se suben al repositorio.

## 2. Contenido entregado (versión 1.0.0)

```
BuscadorTickets\
├── BuscadorTickets.exe               programa (icono propio, versión 1.0.0+1)
├── LEEME.txt                         guía para el usuario final
├── flutter_windows.dll               motor de Flutter
├── file_selector_windows_plugin.dll  selector de carpeta
├── msvcp140.dll                      runtime de Visual C++ (redistribuible oficial)
├── vcruntime140.dll
├── vcruntime140_1.dll
├── native_assets.json
└── data\                             recursos de la app (icudtl.dat, app.so, flutter_assets)
```

17 archivos, 28,8 MB (ZIP: 11,9 MB). Requisito: Windows 10 u 11 de 64 bits.

La app crea `data_usuario\` (configuración e índice) al primer uso, junto al .exe; si no puede,
usa `%LOCALAPPDATA%\BuscadorTickets` y lo avisa.

## 3. Lista de comprobación antes de entregar

1. [ ] `flutter analyze` sin advertencias y `flutter test` todo en verde.
2. [ ] `scripts\empaquetar.ps1` termina con "Distribución lista".
3. [ ] Descomprimir el ZIP en otra carpeta, abrir el .exe: primer uso, icono propio en la ventana.
4. [ ] Elegir el disco real, buscar `100219`, ABRIR CARPETA y COPIAR RUTA.
5. [ ] Recomendado: copiar `BuscadorTickets\` al disco de tickets (`<unidad>:\BuscadorTickets\`).
6. [ ] Compartir el SHA-256 junto al ZIP si se envía por correo o red.

## 4. Nueva versión

1. Subir `version:` en `pubspec.yaml` (p. ej. `1.0.1+2`): se refleja en las propiedades del .exe y
   en el nombre del ZIP.
2. Ejecutar `scripts\empaquetar.ps1` y repetir la lista del §3.
3. Para actualizar a un usuario basta con reemplazar los archivos del programa; su carpeta
   `data_usuario\` se conserva (si cambia el formato del índice, la app lo regenera sola).

## 5. Icono

`windows/runner/resources/app_icon.ico` (lupa roja con tres líneas sobre fondo negro, como el
encabezado de la app) se genera con `scripts\generar_icono.ps1` (solo System.Drawing, 9 tamaños
de 16 a 256 px). Si se cambia, volver a compilar.

## 6. Firma de código (no incluida)

El .exe no está firmado: al abrirlo por primera vez desde un ZIP descargado, Windows SmartScreen
puede mostrar "Windows protegió su PC" → "Más información" → "Ejecutar de todas formas". Copiado
desde un disco USB o una carpeta compartida normalmente no aparece. Firmarlo requiere un
certificado de firma de código (de pago), fuera del alcance del MVP.
