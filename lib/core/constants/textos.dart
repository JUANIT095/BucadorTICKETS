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
