/// Carpeta de ticket indexada.
///
/// Versión mínima; se completa en la Fase 9 (JSON y campos normalizados).
class Ticket {
  const Ticket({
    this.numero,
    required this.nombre,
    required this.nombreCarpeta,
    required this.anio,
    this.mes,
    required this.carpetaMes,
    required this.rutaRelativa,
  });

  /// Número como texto (conserva ceros); null si la carpeta no empieza por número.
  final String? numero;

  /// Nombre sin el número: "Curación2 ABC - Proyecto IA".
  final String nombre;

  /// Nombre completo de la carpeta: "100219_Curación2 ABC - Proyecto IA".
  final String nombreCarpeta;

  final int anio;

  /// Mes 1–12; null si la carpeta de mes no se reconoce.
  final int? mes;

  /// Nombre original de la carpeta de mes, para mostrar.
  final String carpetaMes;

  /// Ruta relativa a la carpeta raíz.
  final String rutaRelativa;
}
