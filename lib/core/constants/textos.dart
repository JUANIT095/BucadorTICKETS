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
  static const calculando = 'Calculando…';
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
  static const estadoError = 'No se pudo completar la operación';
  static String resultados(int n) =>
      n == 1 ? '1 resultado' : '${_miles(n)} resultados';

  // Avisos y errores
  static const avisoRaizNoDisponible =
      'La carpeta raíz no está disponible. Se muestran resultados del último índice.';
  static const errorLeerIndice =
      'No se pudo leer el índice guardado. Pulsa «Actualizar índice» para generarlo de nuevo.';
  static const cerrarAviso = 'Cerrar aviso';

  // Carpeta raíz
  static const verificandoCarpeta = 'Verificando carpeta...';
  static const seleccionarCarpeta = 'SELECCIONAR CARPETA';
  static const elegirOtraCarpeta = 'ELEGIR OTRA CARPETA';
  static const reintentar = 'REINTENTAR';
  static const usarCarpetaPropuesta = 'USAR LA CARPETA PROPUESTA';
  static const cancelar = 'CANCELAR';
  static const primerUsoTitulo =
      'Selecciona la carpeta donde están las carpetas METADA';
  static const primerUsoDetalle =
      'Si están en un disco externo USB, conéctalo y elige la carpeta que '
      'contiene «METADA 2024», «METADA 2025»… (por ejemplo E:\\DISCO).';
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
  static const motivoSinMetada =
      'Esta carpeta no contiene carpetas METADA (por ejemplo «METADA 2024»).';
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
      '(por ejemplo «METADA 2024»).';
  static String avisoAnioDuplicado(int anio, List<String> carpetas) =>
      'El año $anio aparece en varias carpetas '
      '(${carpetas.map((c) => '«$c»').join(', ')}); se usarán todas.';
  static String carpetaIgnorada(String nombre, bool fueraDeRango) =>
      '«$nombre» (${fueraDeRango ? 'año fuera de rango' : 'nombre no reconocido'})';
  static String avisoCarpetasIgnoradas(List<String> descripciones) =>
      'Se ignoraron carpetas con nombre parecido a METADA: '
      '${descripciones.join(', ')}.';
  static String avisoErroresLectura(int n) => n == 1
      ? 'Una carpeta de la raíz no se pudo leer.'
      : '$n carpetas de la raíz no se pudieron leer.';
  static String avisoDeteccionFallida(String motivo) =>
      'No se pudieron detectar los años. $motivo';

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
