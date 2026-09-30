// Constantes técnicas de la aplicación.

abstract final class AppConstants {
  /// Carpeta de año: "METADA 2024", "metada  2025", "METADA_2024"…
  /// Sin distinguir mayúsculas y tolerando espacios; el grupo 1 es el año.
  static final patronMetada = RegExp(
    r'^\s*metada[\s_\-]*(\d{4})\s*$',
    caseSensitive: false,
  );

  /// Años aceptados en carpetas METADA (sin fijar 2024–2026).
  static const anioMinimo = 2000;
  static const anioMaximo = 2100;

  // Almacenamiento portable
  static const carpetaDatos = 'data_usuario';
  static const carpetaRespaldo = 'BuscadorTickets';
  static const archivoConfig = 'config.json';
  static const versionConfig = 1;

  // Tiempos límite de disco (unidades USB o de red lentas pueden colgarse)
  static const limiteValidacion = Duration(seconds: 5);
  static const limitePorUnidad = Duration(milliseconds: 1500);
}
