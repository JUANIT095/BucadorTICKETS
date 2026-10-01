/// Carpeta dentro de una carpeta de año: un mes reconocido o una carpeta
/// contenedora no reconocida como mes (sus tickets se incluyen igual).
class CarpetaMes {
  const CarpetaMes({
    required this.anio,
    required this.mes,
    required this.nombre,
    required this.ruta,
  });

  final int anio;

  /// Mes 1–12; null si el nombre no se reconoce como mes.
  final int? mes;

  /// Nombre original de la carpeta (se muestra en la tarjeta).
  final String nombre;

  /// Ruta completa.
  final String ruta;

  bool get reconocida => mes != null;
}
