import 'dart:async';
import 'dart:io';

import '../../../core/constants/app_constants.dart';

/// Cuenta las entradas directas (archivos y carpetas) de la carpeta de un
/// ticket. Solo lectura; no entra en subcarpetas.
///
/// Devuelve null si la carpeta ya no existe, no se puede leer o no responde a
/// tiempo: la tarjeta muestra "No disponible" en lugar de un error técnico.
Future<int?> contarElementos(String ruta) async {
  try {
    return await Directory(
      ruta,
    ).list(followLinks: false).length.timeout(AppConstants.limiteValidacion);
  } on TimeoutException {
    return null;
  } on FileSystemException {
    return null;
  }
}
