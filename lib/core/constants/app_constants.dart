// Constantes técnicas de la aplicación.

abstract final class AppConstants {
  /// Carpeta de año: "METADA 2024", "metada  2025", "METADA_2024"…
  /// Sin distinguir mayúsculas y tolerando espacios; el grupo 1 es el año.
  static final patronMetada = RegExp(
    r'^\s*metada[\s_\-]*(\d{4})\s*$',
    caseSensitive: false,
  );

  /// Carpeta de año con el número solo: "2024" (formato real del disco).
  static final patronAnioSolo = RegExp(r'^\s*(\d{4})\s*$');

  /// Nombre de carpeta de año en cualquiera de los dos formatos.
  static bool esNombreDeAnio(String nombre) =>
      patronAnioSolo.hasMatch(nombre) || patronMetada.hasMatch(nombre);

  /// Años aceptados en carpetas METADA (sin fijar 2024–2026).
  static const anioMinimo = 2000;
  static const anioMaximo = 2100;

  // Almacenamiento portable
  static const carpetaDatos = 'data_usuario';
  static const carpetaRespaldo = 'BuscadorTickets';
  static const archivoConfig = 'config.json';
  static const versionConfig = 1;
  static const archivoIndice = 'indice.json';
  static const versionIndice = 1;

  /// Máximo de resultados mostrados (se avisa "mostrando 200 de N").
  static const limiteResultados = 200;

  // Tiempos límite de disco (unidades USB o de red lentas pueden colgarse).
  // Holgados porque un disco USB en reposo tarda varios segundos en
  // despertar (comprobado con el disco real: más de 5 s).
  static const limiteValidacion = Duration(seconds: 15);
  static const limitePorUnidad = Duration(seconds: 10);
}
