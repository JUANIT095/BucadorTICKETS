El proyecto Flutter para Windows ya está creado y compila correctamente (flutter run -d windows funciona).

Realiza las FASES 1 y 2. No escribas código todavía.

FASE 1 – Análisis:
- Resume en tus palabras el problema, la estructura de datos (AÑO > MES > TICKET) y el alcance del MVP.
- Indica ambigüedades o casos límite que detectes: carpetas que no siguen el formato NUMERO_NOMBRE, meses con otro nombre o numerados, tildes, carpetas vacías, rutas de red, etc. Propón cómo manejar cada uno.

FASE 2 – Arquitectura:
1. Estructura de carpetas de lib/ con el propósito de cada archivo.
2. Modelo de datos del ticket.
3. Estrategia de indexación: cómo se recorre el disco, uso de Isolates, formato y ubicación del índice, y cómo se actualiza.
4. Algoritmo de búsqueda y ranking según la prioridad de la sección 8, incluyendo la normalización de mayúsculas y tildes.
5. Gestión de estado: qué enfoque usarás y por qué es el más simple adecuado.
6. Portabilidad: dónde se guardan la configuración y el índice, y qué DLL deben acompañar al .exe.
7. Dependencias de pub.dev: cada una justificada. Si algo se puede hacer sin paquete, dilo.
8. Riesgos técnicos principales.

Al final, crea en docs/PROGRESO.md la lista de las 20 fases con casillas, marca como completadas la 1 y la 2, y espera mi aprobación antes de pasar a la Fase 3.