import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/constants/app_constants.dart';
import '../../../models/carpeta_anio.dart';
import 'parser_carpetas.dart';

enum MotivoIgnorada {
  /// Contiene "metada" pero no cumple el patrón ("METADA 2024 (copia)").
  formatoNoReconocido,

  /// Cumple el patrón pero el año está fuera de 2000–2100.
  anioFueraDeRango,
}

class CarpetaIgnorada {
  const CarpetaIgnorada(this.nombre, this.motivo);

  final String nombre;
  final MotivoIgnorada motivo;
}

enum MotivoFalloDeteccion { noExiste, sinPermisos, noResponde }

sealed class ResultadoDeteccionAnios {
  const ResultadoDeteccionAnios();
}

class DeteccionAnios extends ResultadoDeteccionAnios {
  const DeteccionAnios({
    required this.carpetas,
    this.ignoradas = const [],
    this.erroresLectura = 0,
  });

  /// Carpetas de año, del año más reciente al más antiguo (y por nombre).
  /// Un año puede tener varias carpetas: se conservan todas.
  final List<CarpetaAnio> carpetas;

  final List<CarpetaIgnorada> ignoradas;

  /// Entradas de la raíz que no se pudieron leer.
  final int erroresLectura;

  /// Años distintos, del más reciente al más antiguo.
  List<int> get anios => {for (final c in carpetas) c.anio}.toList();

  /// Años con más de una carpeta ("METADA 2024" y "METADA_2024").
  Map<int, List<String>> get duplicados {
    final porAnio = <int, List<String>>{};
    for (final c in carpetas) {
      (porAnio[c.anio] ??= []).add(c.nombre);
    }
    return {
      for (final MapEntry(key: anio, value: nombres) in porAnio.entries)
        if (nombres.length > 1) anio: nombres,
    };
  }
}

class DeteccionFallida extends ResultadoDeteccionAnios {
  const DeteccionFallida(this.motivo);

  final MotivoFalloDeteccion motivo;
}

/// Detecta las carpetas de año en el primer nivel de la raíz. Solo lectura;
/// no entra en meses ni tickets.
///
/// Sin Isolate: un solo listado de carpeta es E/S asíncrona y no bloquea la UI.
class DetectorAnios {
  const DetectorAnios({this.limite = AppConstants.limiteValidacion});

  final Duration limite;

  Future<ResultadoDeteccionAnios> detectar(String raiz) async {
    try {
      return await _detectar(raiz).timeout(limite);
    } on TimeoutException {
      return const DeteccionFallida(MotivoFalloDeteccion.noResponde);
    }
  }

  Future<ResultadoDeteccionAnios> _detectar(String raiz) async {
    final carpetas = <CarpetaAnio>[];
    final ignoradas = <CarpetaIgnorada>[];
    var errores = 0;

    try {
      final directorio = Directory(raiz);
      if (!await directorio.exists()) {
        return const DeteccionFallida(MotivoFalloDeteccion.noExiste);
      }
      final entradas = directorio
          .list(followLinks: false)
          // Un error en una entrada no corta el listado del resto.
          .handleError(
            (Object _) => errores++,
            test: (e) => e is FileSystemException,
          );
      await for (final entrada in entradas) {
        if (entrada is! Directory) continue;
        final nombre = p.basename(entrada.path);
        final anio = anioDeCarpeta(nombre);
        if (anio == null) {
          if (pareceCarpetaMetada(nombre)) {
            ignoradas.add(
              CarpetaIgnorada(nombre, MotivoIgnorada.formatoNoReconocido),
            );
          }
        } else if (!anioEnRango(anio)) {
          ignoradas.add(
            CarpetaIgnorada(nombre, MotivoIgnorada.anioFueraDeRango),
          );
        } else {
          carpetas.add(
            CarpetaAnio(anio: anio, nombre: nombre, ruta: entrada.path),
          );
        }
      }
    } on FileSystemException {
      return const DeteccionFallida(MotivoFalloDeteccion.sinPermisos);
    }

    carpetas.sort((a, b) {
      final porAnio = b.anio.compareTo(a.anio);
      return porAnio != 0 ? porAnio : a.nombre.compareTo(b.nombre);
    });
    ignoradas.sort((a, b) => a.nombre.compareTo(b.nombre));
    return DeteccionAnios(
      carpetas: carpetas,
      ignoradas: ignoradas,
      erroresLectura: errores,
    );
  }
}
