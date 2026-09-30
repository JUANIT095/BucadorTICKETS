import '../core/constants/app_constants.dart';

/// Configuración persistida en `config.json`.
class Configuracion {
  const Configuracion({required this.raiz, this.raizRelativaExe});

  /// Ruta absoluta de la carpeta raíz.
  final String raiz;

  /// Ruta de la raíz relativa a la carpeta del .exe; solo si ambas están en
  /// la misma unidad (caso disco USB).
  final String? raizRelativaExe;

  /// Devuelve null si el JSON falta, está incompleto o es de otra versión:
  /// se trata como "sin configuración".
  static Configuracion? desdeJson(Map<String, dynamic>? json) {
    if (json == null || json['version'] != AppConstants.versionConfig) {
      return null;
    }
    final raiz = json['raiz'];
    if (raiz is! String || raiz.trim().isEmpty) return null;
    final relativa = json['raizRelativaExe'];
    return Configuracion(
      raiz: raiz,
      raizRelativaExe: relativa is String && relativa.isNotEmpty
          ? relativa
          : null,
    );
  }

  Map<String, dynamic> aJson() => {
    'version': AppConstants.versionConfig,
    'raiz': raiz,
    if (raizRelativaExe != null) 'raizRelativaExe': raizRelativaExe,
  };
}
