# CONTEXTO MAESTRO DEL PROYECTO

**NOMBRE DEL PROYECTO:** Buscador Portable de Tickets
**TECNOLOGÍA:** Flutter + Dart + Windows Desktop
**TIPO DE APLICACIÓN:** Aplicación de escritorio portable para Windows (.EXE)

---

## 1. DESCRIPCIÓN GENERAL DEL PROYECTO

Se requiere desarrollar una aplicación de escritorio para Windows cuyo objetivo principal sea facilitar y acelerar la búsqueda de tickets, proyectos y archivos relacionados que se encuentran almacenados dentro de un disco.

La aplicación será desarrollada utilizando Flutter y Dart para Windows.

El resultado final debe ser un aplicativo ejecutable (.exe) que pueda utilizarse de manera PORTABLE.

Esto significa que el usuario debe poder:

1. Recibir una carpeta con el aplicativo.
2. Copiarla a un ordenador, disco externo o memoria USB.
3. Ejecutar el archivo .exe.
4. Utilizar la aplicación inmediatamente.
5. Realizar búsquedas de tickets.
6. Abrir directamente la carpeta correspondiente al ticket.

NO se debe requerir un proceso tradicional de instalación.

El usuario no debe necesitar instalar Flutter, Dart, Python, Node.js ni ninguna otra herramienta de desarrollo para utilizar la aplicación.

---

## 2. PROBLEMA QUE RESUELVE

Actualmente la información está almacenada dentro de una estructura de carpetas organizada por año, mes y ticket.

Cuando un usuario necesita encontrar un ticket específico, debe navegar manualmente por diferentes carpetas.

Por ejemplo:

```
DISCO
→ METADA 2024
→ Mayo
→ buscar entre múltiples carpetas de tickets
```

Esto puede convertirse en un proceso lento cuando existe una gran cantidad de tickets.

El problema principal que busca solucionar este proyecto es:

> "Permitir encontrar rápidamente un ticket sin que el usuario tenga que navegar manualmente por toda la estructura de carpetas."

La aplicación funcionará como un buscador especializado para la estructura de almacenamiento existente.

---

## 3. ESTRUCTURA REAL DE LOS DATOS

La información está distribuida principalmente en tres carpetas correspondientes a los años:

- METADA 2024
- METADA 2025
- METADA 2026

La estructura general es:

```
DISCO
│
├── METADA 2024
│   ├── Enero
│   ├── Febrero
│   ├── Marzo
│   ├── Abril
│   ├── Mayo
│   ├── Junio
│   ├── Julio
│   ├── Agosto
│   ├── Septiembre
│   ├── Octubre
│   ├── Noviembre
│   └── Diciembre
│
├── METADA 2025
│   ├── Enero ... Diciembre (mismos 12 meses)
│
└── METADA 2026
    ├── Enero ... Diciembre (mismos 12 meses)
```

La jerarquía principal de información es:

```
AÑO
↓
MES
↓
TICKET
↓
CONTENIDO DEL TICKET
```

---

## 4. ESTRUCTURA DE UN TICKET

Dentro de cada carpeta correspondiente a un mes existen diferentes carpetas.

Cada carpeta representa un ticket o proyecto.

Ejemplo:

```
DISCO\METADA 2024\Mayo\100219_Curación2 ABC - Proyecto IA
```

La carpeta `100219_Curación2 ABC - Proyecto IA` representa un ticket.

Dentro de ella se encuentran los archivos y recursos asociados al ticket. Por ejemplo:

```
100219_Curación2 ABC - Proyecto IA
│
├── documento.pdf
├── Brief.docx
├── presentación.pptx
├── imagen.png
├── recursos
│   ├── archivo1
│   └── archivo2
└── otros archivos
```

Por lo tanto, el concepto fundamental del sistema es:

> **TICKET = CARPETA PRINCIPAL**

Los archivos que están dentro de esa carpeta forman parte del contenido del ticket.

---

## 5. IDENTIFICACIÓN DEL TICKET

Normalmente las carpetas utilizan una estructura similar a:

```
NUMERO_TICKET_NOMBRE
```

Ejemplo: `100219_Curación2 ABC - Proyecto IA`

Donde:

- `100219` = número o identificador del ticket
- `Curación2 ABC - Proyecto IA` = nombre o descripción del ticket

La aplicación debe intentar interpretar esta estructura para poder mostrar la información de forma organizada. Por ejemplo:

- **Número:** 100219
- **Nombre:** Curación2 ABC - Proyecto IA
- **Año:** 2024
- **Mes:** Mayo
- **Ruta:** D:...\METADA 2024\Mayo\100219_Curación2 ABC - Proyecto IA

---

## 6. OBJETIVO PRINCIPAL DE LA APLICACIÓN

El objetivo es transformar una estructura de almacenamiento compleja:

```
AÑO → MES → TICKET → ARCHIVOS
```

en una experiencia sencilla:

```
BUSCAR → ENCONTRAR → ABRIR
```

El usuario no debería necesitar conocer exactamente dónde está almacenado el ticket.

Por ejemplo, si necesita encontrar `100219`, simplemente escribe `100219` y la aplicación debe localizar `100219_Curación2 ABC - Proyecto IA`.

---

## 7. BÚSQUEDA DE TICKETS

La búsqueda debe permitir encontrar tickets mediante diferentes criterios. Debe ser posible buscar por:

- Número de ticket.
- Parte del número.
- Nombre del ticket.
- Parte del nombre.
- Palabras clave.
- Nombre completo.

Ejemplos (todos deben devolver `100219_Curación2 ABC - Proyecto IA`):

| Búsqueda | Resultado |
|---|---|
| `100219` | 100219_Curación2 ABC - Proyecto IA |
| `Curación2` | 100219_Curación2 ABC - Proyecto IA |
| `Proyecto IA` | 100219_Curación2 ABC - Proyecto IA |
| `100219_Curación2 ABC - Proyecto IA` | 100219_Curación2 ABC - Proyecto IA |

La búsqueda debe ignorar diferencias entre mayúsculas y minúsculas.

Ejemplo: `CURACION2`, `curacion2` y `Curacion2` deben considerarse equivalentes cuando sea técnicamente posible.

---

## 8. BÚSQUEDA INTELIGENTE

La aplicación debe priorizar las coincidencias más relevantes.

Prioridad:

1. Coincidencia exacta del número del ticket.
2. Coincidencia parcial del número.
3. Coincidencia al inicio del nombre.
4. Coincidencia dentro del nombre.
5. Coincidencia por palabras clave.

Por ejemplo, si el usuario busca `100219`, el ticket `100219_Curación2 ABC - Proyecto IA` debe aparecer antes que otros resultados menos relevantes.

---

## 9. FILTROS

La aplicación debe contemplar filtros para facilitar la búsqueda.

**AÑO:** Todos, 2024, 2025, 2026

**MES:** Todos, Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre

Ejemplo: Buscar `100219`, Año `2024`, Mes `Mayo`.

Esto permitirá reducir los resultados.

---

## 10. CARPETA RAÍZ

La aplicación NO debe asumir que el almacenamiento siempre está ubicado en una unidad específica.

Por ejemplo, no se debe asumir permanentemente `D:\DISCO`.

La aplicación debe permitir que el usuario seleccione la carpeta raíz donde se encuentra la estructura METADA.

Ejemplo: `D:\DISCO`

Una vez seleccionada, la aplicación debe detectar:

- `D:\DISCO\METADA 2024`
- `D:\DISCO\METADA 2025`
- `D:\DISCO\METADA 2026`

La carpeta raíz debe poder configurarse desde la aplicación.

---

## 11. INDEXACIÓN

Debido a que puede existir una gran cantidad de tickets y archivos, no es recomendable recorrer todo el disco cada vez que el usuario realiza una búsqueda.

La aplicación debe utilizar una estrategia de indexación.

El índice debe almacenar principalmente información de las carpetas de tickets. Como mínimo:

- Número de ticket.
- Nombre.
- Año.
- Mes.
- Ruta.

Ejemplo conceptual:

- **Ticket:** 100219
- **Nombre:** Curación2 ABC - Proyecto IA
- **Año:** 2024
- **Mes:** Mayo
- **Ruta:** D:\DISCO\METADA 2024\Mayo\100219_Curación2 ABC - Proyecto IA

El objetivo del índice es permitir búsquedas rápidas.

---

## 12. ACTUALIZACIÓN DEL ÍNDICE

La estructura de carpetas puede cambiar con el tiempo. Pueden aparecer:

- Nuevos tickets.
- Nuevos meses.
- Nuevos archivos.
- Carpetas eliminadas.
- Tickets renombrados.

Por eso la aplicación debe contemplar una función para actualizar el índice.

Inicialmente puede existir un botón: **"Actualizar índice"**

La aplicación debe volver a analizar la estructura cuando el usuario lo solicite.

Posteriormente se puede evaluar una actualización automática.

---

## 13. INTERFAZ DE USUARIO

La interfaz debe ser moderna, profesional y extremadamente sencilla.

La búsqueda debe ser el elemento principal de la pantalla.

La pantalla inicial debe contener:

- **Título:** BUSCADOR DE TICKETS
- **Campo de búsqueda:** "Buscar ticket, proyecto o palabra clave..."
- **Botón:** BUSCAR

La aplicación debe evitar interfaces saturadas.

El usuario debe poder comenzar una búsqueda inmediatamente después de abrir el programa.

---

## 14. RESULTADOS

Los resultados deben mostrarse mediante tarjetas o elementos visuales claros.

Ejemplo:

```
---------------------------------------------
📁 100219_Curación2 ABC - Proyecto IA

Ticket:     100219
Año:        2024
Mes:        Mayo
Ubicación:  D:\DISCO\METADA 2024\Mayo\100219_Curación2 ABC - Proyecto IA
Elementos:  12 archivos

[ABRIR CARPETA]   [COPIAR RUTA]
---------------------------------------------
```

---

## 15. ACCIONES SOBRE EL RESULTADO

Cada resultado debe permitir:

1. Abrir carpeta.
2. Copiar ruta.

**ABRIR CARPETA:** Debe abrir el Explorador de archivos de Windows directamente en la carpeta del ticket.

**COPIAR RUTA:** Debe copiar la ruta completa al portapapeles.

La aplicación NO debe modificar los archivos.

---

## 16. CONTENIDO DEL TICKET

Después de localizar un ticket, la aplicación puede mostrar información básica sobre su contenido.

Por ejemplo:

Ticket: `100219_Curación2 ABC - Proyecto IA`

Contenido:

- Brief.docx
- documento.pdf
- presentación.pptx
- Recursos

Esta funcionalidad debe considerarse parte de la evolución del proyecto.

La prioridad inicial es encontrar la carpeta del ticket.

---

## 17. BÚSQUEDA DENTRO DEL TICKET

Como funcionalidad futura, se puede implementar una segunda búsqueda: **"Buscar dentro del ticket"**

Por ejemplo, en el ticket `100219_Curación2 ABC - Proyecto IA` el usuario podría buscar: Brief, OVA, Presentación, PDF.

Esto permitiría encontrar archivos específicos dentro del ticket.

Esta funcionalidad no debe complicar ni ralentizar la búsqueda principal del MVP.

---

## 18. BÚSQUEDA POR CONTENIDO

Como funcionalidad futura, se puede evaluar la búsqueda del contenido interno de documentos.

Ejemplo: Buscar "Proyecto IA" y encontrar documentos que contengan esa frase.

Sin embargo, esta funcionalidad NO es prioritaria.

Primero debe completarse y validarse la búsqueda por nombre de carpeta/ticket.

---

## 19. FUNCIONAMIENTO OFFLINE

La aplicación debe funcionar sin conexión a Internet.

No debe depender de:

- APIs externas.
- Servidores.
- Firebase.
- Supabase.
- Bases de datos remotas.
- Servicios cloud.

La búsqueda debe ejecutarse localmente.

---

## 20. PORTABILIDAD

Este es uno de los requisitos más importantes.

El usuario debe poder ejecutar el aplicativo sin instalarlo.

El resultado será una carpeta portable. Ejemplo:

```
BuscadorTickets
│
├── BuscadorTickets.exe
├── flutter_windows.dll
├── data
└── archivos necesarios
```

El usuario debe poder copiar esta carpeta a otro ordenador Windows compatible y ejecutar `BuscadorTickets.exe`.

No debe ser necesario ejecutar un instalador.

---

## 21. REQUISITOS DEL ORDENADOR DESTINO

El ordenador donde se utilice la aplicación no debe necesitar:

- Flutter.
- Dart.
- Visual Studio.
- Node.js.
- Python.
- Herramientas de desarrollo.

Todas las dependencias necesarias para ejecutar la aplicación deben formar parte de la distribución Release de Flutter.

---

## 22. SEGURIDAD

La aplicación tendrá inicialmente un comportamiento de SOLO LECTURA.

No debe:

- Eliminar archivos.
- Mover archivos.
- Renombrar archivos.
- Modificar archivos.
- Sobrescribir archivos.

Sus funciones principales serán:

- Leer estructura de carpetas.
- Leer información básica de archivos.
- Buscar.
- Mostrar resultados.
- Abrir carpetas.
- Copiar rutas.

---

## 23. RENDIMIENTO

La aplicación debe estar diseñada pensando en grandes cantidades de tickets.

La interfaz no debe congelarse durante:

- Indexación.
- Búsqueda.
- Actualización del índice.

Se debe utilizar procesamiento asíncrono cuando sea necesario.

La IA debe evaluar técnicamente el uso de:

- Isolates de Dart.
- Caché.
- Indexación local.
- Procesamiento incremental.

La solución debe priorizar simplicidad y rendimiento.

---

## 24. MANEJO DE ERRORES

La aplicación debe manejar correctamente situaciones como:

- Carpeta raíz inexistente.
- Disco desconectado.
- Carpeta de red no disponible.
- Falta de permisos.
- Ticket eliminado.
- Archivo eliminado.
- Ruta inaccesible.
- Error de lectura.

Los errores deben mostrarse mediante mensajes claros.

No mostrar mensajes técnicos incomprensibles al usuario final.

---

## 25. ESTADOS DE LA INTERFAZ

La aplicación debe contemplar como mínimo:

- **ESTADO INICIAL:** "Busca un ticket para comenzar"
- **ESTADO DE BÚSQUEDA:** "Buscando..."
- **ESTADO CON RESULTADOS:** Mostrar las carpetas encontradas.
- **ESTADO SIN RESULTADOS:** "No encontramos ningún ticket." / "Intenta con otro número o palabra clave."
- **ESTADO DE ERROR:** Mostrar un mensaje claro explicando qué ocurrió.

---

## 26. ARQUITECTURA DEL PROYECTO

El proyecto debe mantenerse organizado. Se recomienda una estructura similar a:

```
lib/
│
├── core/
│   ├── constants/
│   ├── services/
│   ├── theme/
│   └── utils/
│
├── models/
│
├── features/
│   └── search/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── widgets/
│
└── main.dart
```

La arquitectura puede modificarse si existe una razón técnica clara.

No introducir complejidad innecesaria.

---

## 27. TECNOLOGÍAS

- **Tecnología principal:** Flutter
- **Lenguaje:** Dart
- **Plataforma:** Windows Desktop

No utilizar:

- Electron
- React Desktop
- Python como aplicación principal
- Node.js como aplicación principal

Flutter debe encargarse de la interfaz y Dart de la lógica de aplicación.

---

## 28. MVP

La primera versión funcional debe incluir únicamente:

1. Aplicación Flutter Windows.
2. Interfaz principal.
3. Selección de carpeta raíz.
4. Detección de METADA 2024.
5. Detección de METADA 2025.
6. Detección de METADA 2026.
7. Detección de meses.
8. Detección de carpetas de tickets.
9. Identificación del número de ticket.
10. Identificación del nombre.
11. Indexación.
12. Búsqueda.
13. Resultados.
14. Filtros por año.
15. Filtros por mes.
16. Abrir carpeta.
17. Copiar ruta.
18. Actualizar índice.
19. Manejo de errores.
20. Generación del EXE portable.

---

## 29. FUNCIONALIDADES FUTURAS

Después de validar el MVP se pueden agregar:

- Historial de búsquedas.
- Tickets favoritos.
- Búsqueda dentro del ticket.
- Visualización de archivos.
- Búsqueda por extensión.
- Filtros por fecha.
- Filtros por tamaño.
- Búsqueda dentro del contenido de documentos.
- Actualización automática del índice.
- Atajos de teclado.
- Modo oscuro.
- Personalización visual.
- Estadísticas.

Estas funcionalidades NO deben implementarse antes de validar correctamente el MVP.

---

## 30. EXPERIENCIA DE USUARIO OBJETIVO

La experiencia principal debe ser:

```
ABRIR APLICACIÓN
↓
ESCRIBIR TICKET
↓
BUSCAR
↓
ENCONTRAR TICKET
↓
ABRIR CARPETA
```

Ejemplo:

1. El usuario necesita encontrar `100219`.
2. Abre `BuscadorTickets.exe`.
3. Escribe `100219`.
4. La aplicación muestra:
   - `100219_Curación2 ABC - Proyecto IA`
   - `2024 / Mayo`
   - `D:\DISCO\METADA 2024\Mayo\100219_Curación2 ABC - Proyecto IA`
5. El usuario pulsa **ABRIR CARPETA**.
6. Windows abre directamente la carpeta.

---

## 31. PRINCIPIOS DE DISEÑO

La aplicación debe seguir estos principios:

- **SIMPLICIDAD:** El usuario debe entender inmediatamente cómo utilizarla.
- **RAPIDEZ:** La búsqueda debe ser rápida.
- **CLARIDAD:** Los resultados deben mostrar información relevante.
- **PORTABILIDAD:** Debe ejecutarse sin instalación.
- **SEGURIDAD:** No debe modificar los datos originales.
- **ESCALABILIDAD:** La arquitectura debe permitir agregar funcionalidades posteriormente.

---

## 32. METODOLOGÍA DE DESARROLLO

La IA desarrolladora debe trabajar por fases.

No debe crear todo el proyecto de una sola vez.

El orden recomendado es:

1. **FASE 1:** Análisis del contexto.
2. **FASE 2:** Arquitectura.
3. **FASE 3:** Configuración Flutter Windows.
4. **FASE 4:** Interfaz.
5. **FASE 5:** Selección de carpeta raíz.
6. **FASE 6:** Detección de años.
7. **FASE 7:** Detección de meses.
8. **FASE 8:** Detección de tickets.
9. **FASE 9:** Modelo de datos.
10. **FASE 10:** Indexación.
11. **FASE 11:** Motor de búsqueda.
12. **FASE 12:** Resultados.
13. **FASE 13:** Abrir carpeta.
14. **FASE 14:** Copiar ruta.
15. **FASE 15:** Filtros.
16. **FASE 16:** Optimización.
17. **FASE 17:** Pruebas.
18. **FASE 18:** Build Release.
19. **FASE 19:** Prueba de portabilidad.
20. **FASE 20:** Preparación de distribución.

---

## 33. REGLAS PARA LA IA DESARROLLADORA

Antes de escribir código:

1. Leer completamente este documento.
2. Comprender la estructura de almacenamiento.
3. Comprender que una carpeta de ticket es la unidad principal de búsqueda.
4. Analizar los requisitos.
5. Proponer la arquitectura.
6. Explicar la estrategia de indexación.
7. Explicar cómo se garantizará la portabilidad.
8. Explicar las dependencias necesarias.
9. Dividir el proyecto en fases.

Durante el desarrollo:

- Explicar las decisiones técnicas.
- No generar código innecesario.
- Mantener una arquitectura organizada.
- Mantener el código simple.
- No modificar los archivos originales.
- No agregar servicios externos sin autorización.
- No asumir rutas fijas.
- No asumir que siempre existe D:.
- No bloquear la interfaz.
- Validar cada fase antes de continuar.

---

## 34. RESULTADO FINAL ESPERADO

El resultado debe ser una aplicación Windows portable llamada **BuscadorTickets**.

El usuario deberá poder ejecutar `BuscadorTickets.exe` y utilizar inmediatamente el buscador.

La aplicación debe convertir esta estructura:

```
DISCO → METADA 2024 → Mayo → 100219_Curación2 ABC - Proyecto IA → archivos
```

en una experiencia:

- **BUSCAR:** 100219
- **RESULTADO:** 100219_Curación2 ABC - Proyecto IA
- **ACCIÓN:** ABRIR CARPETA

---

## 35. VISIÓN DEL PROYECTO

La visión final del proyecto es crear una herramienta interna especializada que permita localizar rápidamente cualquier ticket almacenado dentro de la estructura METADA sin que el usuario tenga que conocer la ubicación física del ticket.

La aplicación debe actuar como una capa sencilla de búsqueda sobre la estructura existente.

No se pretende reemplazar ni modificar el sistema de almacenamiento actual.

Se pretende facilitar el acceso a la información existente.

La filosofía principal del proyecto es:

> **"Buscar rápidamente, encontrar fácilmente y abrir directamente."**

---

*FIN DEL CONTEXTO*
