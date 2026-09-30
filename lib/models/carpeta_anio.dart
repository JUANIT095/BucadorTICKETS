/// Carpeta de año dentro de la raíz ("METADA 2024").
class CarpetaAnio {
  const CarpetaAnio({
    required this.anio,
    required this.nombre,
    required this.ruta,
  });

  final int anio;

  /// Nombre original de la carpeta.
  final String nombre;

  /// Ruta completa.
  final String ruta;
}
