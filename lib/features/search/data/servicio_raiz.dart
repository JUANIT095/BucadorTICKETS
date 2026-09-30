import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/constants/app_constants.dart';
import '../../../models/configuracion.dart';

/// Resultado de validar una carpeta como raíz. Nunca se lanzan excepciones
/// hacia la interfaz.
sealed class ValidacionRaiz {
  const ValidacionRaiz();
}

class RaizValida extends ValidacionRaiz {
  const RaizValida(this.ruta);

  final String ruta;
}

/// No existe o el disco está desconectado.
class RaizNoExiste extends ValidacionRaiz {
  const RaizNoExiste();
}

/// Sin permisos o error de lectura.
class RaizSinPermisos extends ValidacionRaiz {
  const RaizSinPermisos();
}

/// Se agotó el tiempo límite (unidad lenta o colgada).
class RaizNoResponde extends ValidacionRaiz {
  const RaizNoResponde();
}

class RaizSinMetada extends ValidacionRaiz {
  const RaizSinMetada();
}

/// Se eligió una carpeta METADA; la raíz probablemente es [padre].
class RaizEsCarpetaMetada extends ValidacionRaiz {
  const RaizEsCarpetaMetada(this.padre);

  final String padre;
}

sealed class ResolucionRaiz {
  const ResolucionRaiz();
}

class ResolucionSinConfiguracion extends ResolucionRaiz {
  const ResolucionSinConfiguracion();
}

class ResolucionEncontrada extends ResolucionRaiz {
  const ResolucionEncontrada(this.ruta, {required this.cambioDeUbicacion});

  final String ruta;

  /// La raíz apareció en otra ruta que la guardada (p. ej. otra letra).
  final bool cambioDeUbicacion;
}

class ResolucionNoEncontrada extends ResolucionRaiz {
  const ResolucionNoEncontrada(
    this.ultimaRuta, {
    this.coincidencias = const [],
  });

  final String ultimaRuta;

  /// Si hay varias, la ruta existe en más de una unidad y elige el usuario.
  final List<String> coincidencias;
}

/// Validación y resolución de la carpeta raíz. Solo lectura.
class ServicioRaiz {
  ServicioRaiz({
    required this.rutaExe,
    required this.unidades,
    this.limiteValidacion = AppConstants.limiteValidacion,
    this.limitePorUnidad = AppConstants.limitePorUnidad,
  });

  final String rutaExe;

  /// Raíces de las unidades disponibles (`C:\`, `E:\`…). Inyectable para
  /// poder simular cambios de letra en las pruebas.
  final Future<List<String>> Function() unidades;

  final Duration limiteValidacion;
  final Duration limitePorUnidad;

  String get _carpetaExe => p.dirname(rutaExe);

  Future<ValidacionRaiz> validar(String ruta, {Duration? limite}) async {
    final normalizada = p.normalize(ruta);
    try {
      return await _validar(normalizada).timeout(limite ?? limiteValidacion);
    } on TimeoutException {
      return const RaizNoResponde();
    }
  }

  Future<ValidacionRaiz> _validar(String ruta) async {
    try {
      final carpeta = Directory(ruta);
      if (!await carpeta.exists()) return const RaizNoExiste();
      if (AppConstants.patronMetada.hasMatch(p.basename(ruta))) {
        return RaizEsCarpetaMetada(p.dirname(ruta));
      }
      await for (final entrada in carpeta.list(followLinks: false)) {
        if (entrada is Directory &&
            AppConstants.patronMetada.hasMatch(p.basename(entrada.path))) {
          return RaizValida(ruta);
        }
      }
      return const RaizSinMetada();
    } on FileSystemException {
      return const RaizSinPermisos();
    }
  }

  /// Orden: relativa al .exe → absoluta → misma ruta en otra unidad.
  Future<ResolucionRaiz> resolver(Configuracion? config) async {
    if (config == null) return const ResolucionSinConfiguracion();

    final relativa = config.raizRelativaExe;
    if (relativa != null) {
      final candidata = p.normalize(p.join(_carpetaExe, relativa));
      if (await validar(candidata) is RaizValida) {
        return ResolucionEncontrada(
          candidata,
          cambioDeUbicacion: !p.equals(candidata, config.raiz),
        );
      }
    }

    if (await validar(config.raiz) is RaizValida) {
      return ResolucionEncontrada(config.raiz, cambioDeUbicacion: false);
    }

    if (_esUnc(config.raiz)) return ResolucionNoEncontrada(config.raiz);

    final unidadOriginal = p.rootPrefix(config.raiz);
    final resto = config.raiz.substring(unidadOriginal.length);
    final candidatas = [
      for (final unidad in await unidades())
        if (!p.equals(unidad, unidadOriginal)) p.join(unidad, resto),
    ];
    final resultados = await Future.wait(
      candidatas.map((c) => validar(c, limite: limitePorUnidad)),
    );
    final validas = [
      for (var i = 0; i < candidatas.length; i++)
        if (resultados[i] is RaizValida) p.normalize(candidatas[i]),
    ];

    if (validas.length == 1) {
      return ResolucionEncontrada(validas.single, cambioDeUbicacion: true);
    }
    return ResolucionNoEncontrada(config.raiz, coincidencias: validas);
  }

  /// Configuración para [raiz]; agrega la ruta relativa al .exe solo si ambas
  /// están en la misma unidad (y no son rutas de red).
  Configuracion configuracionPara(String raiz) {
    final mismaUnidad =
        !_esUnc(raiz) &&
        !_esUnc(_carpetaExe) &&
        p.rootPrefix(raiz).toLowerCase() ==
            p.rootPrefix(_carpetaExe).toLowerCase();
    return Configuracion(
      raiz: raiz,
      raizRelativaExe: mismaUnidad ? p.relative(raiz, from: _carpetaExe) : null,
    );
  }

  static bool _esUnc(String ruta) =>
      ruta.startsWith(r'\\') || ruta.startsWith('//');

  /// Unidades de Windows presentes, de `C:` a `Z:` (se omiten A: y B:).
  static Future<List<String>> unidadesDelSistema() async {
    final letras = [
      for (var c = 'C'.codeUnitAt(0); c <= 'Z'.codeUnitAt(0); c++)
        '${String.fromCharCode(c)}:\\',
    ];
    final presentes = await Future.wait(letras.map(_unidadPresente));
    return [
      for (var i = 0; i < letras.length; i++)
        if (presentes[i]) letras[i],
    ];
  }

  static Future<bool> _unidadPresente(String unidad) async {
    try {
      return await Directory(
        unidad,
      ).exists().timeout(AppConstants.limitePorUnidad);
    } on TimeoutException {
      return false;
    } on FileSystemException {
      return false;
    }
  }
}
