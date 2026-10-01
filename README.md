# Buscador de Tickets

Aplicación de escritorio **portable** para Windows (Flutter + Dart) que busca carpetas de tickets
en la estructura `RAÍZ\<año>\<Mes>\<NÚMERO>_<Nombre>` y permite abrir la carpeta en el
Explorador o copiar su ruta. Sin instalación, sin Internet y en **solo lectura** sobre los datos.

## Uso (usuario final)

Descomprimir `BuscadorTickets-<versión>-windows-x64.zip`, abrir `BuscadorTickets.exe` y elegir la
unidad o carpeta que contiene las carpetas de año. Instrucciones completas en
[windows/distribucion/LEEME.txt](windows/distribucion/LEEME.txt), que se entrega junto al .exe.

## Desarrollo

Requisitos: Flutter 3.41 (Dart ^3.11) y Visual Studio con "Desarrollo para el escritorio con C++".

```
flutter pub get
flutter run -d windows        # ejecutar
flutter analyze               # análisis estático
flutter test                  # 183 pruebas
```

## Distribución

```
powershell -ExecutionPolicy Bypass -File scripts\empaquetar.ps1
```

Genera `dist\BuscadorTickets\` y `dist\BuscadorTickets-<versión>-windows-x64.zip` (+ SHA-256).
Detalles en [docs/DISTRIBUCION.md](docs/DISTRIBUCION.md).

## Documentación

- [docs/CONTEXTO_MAESTRO.md](docs/CONTEXTO_MAESTRO.md): requisitos del proyecto.
- [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md): arquitectura, índice, búsqueda, portabilidad y casos límite.
- [docs/PRUEBAS.md](docs/PRUEBAS.md): pruebas automáticas, manuales y de portabilidad.
- [docs/PROGRESO.md](docs/PROGRESO.md): avance por fases.
