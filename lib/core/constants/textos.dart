// Textos visibles para el usuario, centralizados en un solo lugar.

abstract final class Textos {
  // Aplicación y encabezado
  static const tituloApp = 'Buscador de Tickets';
  static const tituloPantalla = 'BUSCADOR DE TICKETS';
  static const sinCarpeta = 'Sin carpeta seleccionada';
  static const cambiarCarpeta = 'Cambiar carpeta';
  static const actualizarIndice = 'Actualizar índice';

  // Búsqueda y filtros
  static const pistaBusqueda = 'Buscar ticket, proyecto o palabra clave...';
  static const buscar = 'BUSCAR';
  static const filtroAnio = 'Año';
  static const filtroMes = 'Mes';
  static const todos = 'Todos';
  static const meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  // Tarjeta de resultado
  static const etiquetaTicket = 'Ticket';
  static const etiquetaAnio = 'Año';
  static const etiquetaMes = 'Mes';
  static const etiquetaUbicacion = 'Ubicación';
  static const etiquetaElementos = 'Elementos';
  static const sinNumero = 'Sin número';
  static const sinMes = 'Sin mes';
  static const calculando = 'Calculando…';
  static const elementosNoDisponible = 'No disponible';
  static const abrirCarpeta = 'ABRIR CARPETA';
  static const copiarRuta = 'COPIAR RUTA';
  static String elementos(int n) =>
      n == 1 ? '1 elemento' : '${_miles(n)} elementos';

  // Estados de la pantalla
  static const estadoInicial = 'Busca un ticket para comenzar';
  static const estadoInicialDetalle =
      'Escribe un número, un nombre o una palabra clave.';
  static const estadoBuscando = 'Buscando...';
  static const estadoIndexando = 'Indexando carpetas...';
  static const estadoIndexandoDetalle = 'Esto puede tardar unos segundos.';
  static const sinResultados = 'No encontramos ningún ticket.';
  static const sinResultadosDetalle =
      'Intenta con otro número o palabra clave.';
  static const sinResultadosConFiltros =
      'Intenta con otro número o palabra clave, o cambia los filtros de año y mes.';
  static const estadoError = 'No se pudo completar la operación';
  static String resultadosLimitados(int mostrados, int total) =>
      'Mostrando $mostrados de ${_miles(total)} resultados. '
      'Escribe más para afinar la búsqueda.';
  static String resultados(int n) =>
      n == 1 ? '1 resultado' : '${_miles(n)} resultados';

  // Avisos y errores
  static const cerrarAviso = 'Cerrar aviso';

  // Carpeta raíz
  static const verificandoCarpeta = 'Verificando carpeta...';
  static const seleccionarCarpeta = 'SELECCIONAR CARPETA';
  static const elegirOtraCarpeta = 'ELEGIR OTRA CARPETA';
  static const reintentar = 'REINTENTAR';
  static const usarCarpetaPropuesta = 'USAR LA CARPETA PROPUESTA';
  static const cancelar = 'CANCELAR';
  static const primerUsoTitulo =
      'Selecciona la unidad o carpeta donde están las carpetas de año';
  static const primerUsoDetalle =
      'Si están en un disco externo USB, conéctalo y elige la unidad o carpeta '
      'que contiene las carpetas «2024», «2025»… (por ejemplo, la unidad completa del disco).';
  static const noEncontradaTitulo = 'No se encuentra la carpeta raíz';
  static const noEncontradaDetalle =
      'Puede que el disco esté desconectado o haya cambiado de ubicación. '
      'Conéctalo y pulsa Reintentar, o elige otra carpeta.';
  static String noEncontradaVarias(List<String> rutas) =>
      'La carpeta aparece en varias unidades (${rutas.join(', ')}). '
      'Elige la correcta.';
  static String ultimaUbicacion(String ruta) => 'Última ubicación: $ruta';
  static const invalidaTitulo = 'Esta carpeta no sirve como raíz';
  static const propuestaTitulo = 'Parece que elegiste una carpeta de año';
  static String propuestaDetalle(String seleccionada, String padre) =>
      'Seleccionaste «$seleccionada». La carpeta raíz probablemente es '
      '$padre.';
  static const motivoNoExiste =
      'La carpeta no existe o el disco está desconectado.';
  static const motivoSinPermisos = 'No hay permisos para leer esta carpeta.';
  static const motivoNoResponde =
      'La unidad no responde. Si es un disco USB o de red, revisa la conexión.';
  static const motivoSinAnios =
      'Esta carpeta no contiene carpetas de año (por ejemplo «2024»).';
  static String avisoCarpetaNoValida(String motivo) =>
      'No se cambió la carpeta raíz. $motivo';
  static String avisoRaizDetectada(String ruta) =>
      'Se detectó la carpeta raíz en $ruta.';
  static String avisoRespaldo(String carpeta) =>
      'No se puede escribir junto al programa. La configuración se guarda en '
      '$carpeta.';
  static const avisoSoloMemoria =
      'No se puede guardar la configuración: se perderá al cerrar el programa.';
  static const avisoConfigNoGuardada =
      'No se pudo guardar la configuración de la carpeta raíz.';

  // Detección de años
  static const sinAnios =
      'La carpeta raíz no tiene carpetas de año válidas '
      '(por ejemplo «2024»).';
  static String avisoAnioDuplicado(int anio, List<String> carpetas) =>
      'El año $anio aparece en varias carpetas '
      '(${carpetas.map((c) => '«$c»').join(', ')}); se usarán todas.';
  static String carpetaIgnorada(String nombre, bool fueraDeRango) =>
      '«$nombre» (${fueraDeRango ? 'año fuera de rango' : 'nombre no reconocido'})';
  static String avisoCarpetasIgnoradas(List<String> descripciones) =>
      'Se ignoraron carpetas con nombre parecido a una carpeta de año: '
      '${descripciones.join(', ')}.';
  static String avisoErroresLectura(int n) => n == 1
      ? 'Una carpeta no se pudo leer.'
      : '$n carpetas no se pudieron leer.';
  static String avisoDeteccionFallida(String motivo) =>
      'No se pudieron detectar los años. $motivo';

  // Detección de meses
  static String avisoMesDuplicado(int anio, int mes, List<String> carpetas) =>
      '${meses[mes - 1]} de $anio aparece en varias carpetas '
      '(${_lista(carpetas.map((c) => '«$c»'))}); se usarán todas.';
  static String avisoMesesNoReconocidos(List<String> carpetas) =>
      'Carpetas no reconocidas como mes (sus tickets se incluirán igual): '
      '${_lista(carpetas.map((c) => '«$c»'))}.';
  static String avisoTicketsSinMes(int n) => n == 1
      ? 'Una carpeta parece un ticket guardado directamente en la carpeta del '
            'año; se incluirá como ticket sin mes.'
      : '$n carpetas parecen tickets guardados directamente en la carpeta '
            'del año; se incluirán como tickets sin mes.';
  static String avisoAniosIlegibles(List<String> carpetas) =>
      'No se pudieron leer los meses de '
      '${_lista(carpetas.map((c) => '«$c»'))}.';

  static String avisoMesesIlegibles(List<String> carpetas) =>
      'No se pudieron leer los tickets de '
      '${_lista(carpetas.map((c) => '«$c»'))}.';

  /// Une hasta 5 elementos y resume el resto: "a, b, c, d, e y 3 más".
  static String _lista(Iterable<String> elementos) {
    final todos = elementos.toList();
    if (todos.length <= 5) return todos.join(', ');
    return '${todos.take(5).join(', ')} y ${todos.length - 5} más';
  }

  // Índice
  static String avisoSinConexion(String ruta) =>
      'La carpeta raíz ($ruta) no está disponible. Se muestran resultados del '
      'último índice; conecta el disco y pulsa «Actualizar índice».';
  static const avisoIndiceRegenerado =
      'El índice guardado estaba dañado o era de otra versión; se generó de nuevo.';
  static const avisoIndiceNoGuardado =
      'No se pudo guardar el índice; se volverá a generar la próxima vez.';
  static const errorIndexar =
      'No se pudo generar el índice. Comprueba que el disco esté conectado y '
      'pulsa «Actualizar índice».';

  // Abrir carpeta
  static String carpetaCercanaAbierta(String ruta) =>
      'La ruta es demasiado larga para que Windows la abra directamente; se '
      'abrió la carpeta más cercana: $ruta';
  static const ticketNoEncontrado =
      'Este ticket ya no está en esa ubicación. Pulsa «Actualizar índice».';
  static const unidadNoDisponible =
      'No se puede abrir la carpeta: el disco no está conectado o no responde.';
  static const errorAlAbrir = 'No se pudo abrir el Explorador de Windows.';

  // Copiar ruta
  static String rutaCopiada(String ruta) => 'Ruta copiada: $ruta';
  static const errorAlCopiar =
      'No se pudo copiar la ruta. Puedes seleccionarla en la tarjeta y copiarla.';

  // Pie
  static const indiceNoGenerado = 'Índice aún no generado';
  static String indiceActualizado(DateTime fecha) =>
      'Índice actualizado: ${_fecha(fecha)}';
  static String ticketsIndexados(int n) =>
      n == 1 ? '1 ticket indexado' : '${_miles(n)} tickets indexados';

  static String _dosDigitos(int v) => v.toString().padLeft(2, '0');

  static String _fecha(DateTime f) =>
      '${_dosDigitos(f.day)}/${_dosDigitos(f.month)}/${f.year} '
      '${_dosDigitos(f.hour)}:${_dosDigitos(f.minute)}';

  /// 12345 → "12.345".
  static String _miles(int n) => n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
}
