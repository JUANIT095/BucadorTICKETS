# BuscadorTickets — Instrucciones para Claude Code

Aplicación de escritorio **portable** para Windows (Flutter + Dart) que busca carpetas de tickets
dentro de la estructura `RAIZ\METADA <AÑO>\<Mes>\<NUMERO>_<Nombre>` y permite abrir la carpeta o copiar su ruta.

El contexto completo y obligatorio del proyecto está aquí (léelo antes de cualquier fase):
@docs/CONTEXTO_MAESTRO.md

El avance de las fases se registra aquí:
@docs/PROGRESO.md

## Reglas de trabajo
- Trabaja UNA fase a la vez (sección 32 del contexto). No adelantes fases ni funcionalidades futuras (sección 29).
- Antes de escribir código de una fase: explica el plan y las decisiones técnicas, y espera mi aprobación.
- Al terminar una fase: indica cómo validarla (`flutter analyze`, `flutter test`, `flutter run -d windows`),
  actualiza `docs/PROGRESO.md` y propone el mensaje de commit.
- Explica en español.

## Restricciones técnicas
- SOLO LECTURA sobre los datos del usuario: nunca borrar, mover, renombrar ni escribir dentro de la carpeta raíz.
- Nunca asumir rutas fijas ni la unidad `D:`. La carpeta raíz la elige el usuario.
- Sin servicios externos, sin internet, sin Firebase/Supabase. Todo local y offline.
- La UI nunca se bloquea: indexación en un Isolate (`Isolate.run` / `compute`).
- Portabilidad: la configuración y el índice se guardan en un archivo JSON junto al .exe
  (o en una subcarpeta `data_usuario/` al lado del ejecutable), NO en AppData ni el registro.
  Si esa ubicación no es escribible, usar un respaldo y avisar al usuario.
- Minimizar dependencias. Justificar cada paquete de pub.dev antes de agregarlo.
- Mensajes de error claros para el usuario final, sin trazas técnicas en pantalla.

## Convenciones
- Estructura: `lib/core`, `lib/models`, `lib/features/search/{data,domain,presentation}`, `lib/widgets`.
- Nombre del ejecutable: `BuscadorTickets.exe` (BINARY_NAME en `windows/CMakeLists.txt`).
- Comparaciones de búsqueda sin distinguir mayúsculas ni tildes (Curación = curacion).

## Comandos útiles
- Ejecutar: `flutter run -d windows`
- Analizar: `flutter analyze`
- Pruebas: `flutter test`
- Build portable: `flutter build windows --release` → `build\windows\x64\runner\Release\`
