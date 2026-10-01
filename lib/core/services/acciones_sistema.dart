import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants/app_constants.dart';

sealed class ResultadoAbrir {
  const ResultadoAbrir();
}

class CarpetaAbierta extends ResultadoAbrir {
  const CarpetaAbierta();
}

/// La ruta supera el límite de Windows (MAX_PATH) y se abrió [ruta], la
/// carpeta antecesora más cercana que sí se puede abrir.
class CarpetaCercanaAbierta extends ResultadoAbrir {
  const CarpetaCercanaAbierta(this.ruta);

  final String ruta;
}

/// La raíz existe pero el ticket ya no está ahí (movido o renombrado).
class TicketNoEncontrado extends ResultadoAbrir {
  const TicketNoEncontrado();
}

/// La raíz no existe o no responde (disco desconectado o en reposo).
class UnidadNoDisponible extends ResultadoAbrir {
  const UnidadNoDisponible();
}

class ErrorAlAbrir extends ResultadoAbrir {
  const ErrorAlAbrir();
}

/// Lanza el Explorador de Windows con el argumento ya preparado.
typedef LanzarExplorador = Future<void> Function(String argumento);

/// Acciones del sistema sobre un resultado. Nunca modifican archivos.
class AccionesSistema {
  const AccionesSistema({this.lanzar = _lanzarExplorador});

  final LanzarExplorador lanzar;

  /// Límite clásico de rutas de Windows (260 con el carácter nulo final).
  /// El Explorador no abre rutas más largas: abre "Documentos" en su lugar.
  static const maximoRuta = 259;

  /// Abre [ruta] en el Explorador. Comprueba antes que exista: con una ruta
  /// inexistente el Explorador abre "Documentos" sin avisar.
  Future<ResultadoAbrir> abrirCarpeta(
    String ruta, {
    required String raiz,
  }) async {
    try {
      if (!await _existe(ruta)) {
        return await _existe(raiz)
            ? const TicketNoEncontrado()
            : const UnidadNoDisponible();
      }
      final destino = rutaAbrible(ruta);
      await lanzar(argumentoExplorador(destino));
      return destino == ruta
          ? const CarpetaAbierta()
          : CarpetaCercanaAbierta(destino);
    } on TimeoutException {
      return const UnidadNoDisponible();
    } on ProcessException {
      return const ErrorAlAbrir();
    } on FileSystemException {
      return const ErrorAlAbrir();
    }
  }

  static Future<bool> _existe(String ruta) =>
      Directory(ruta).exists().timeout(AppConstants.limiteValidacion);

  /// [ruta] o, si supera [maximoRuta], su antecesora más cercana que no lo
  /// supere.
  static String rutaAbrible(String ruta) {
    var actual = ruta;
    while (actual.length > maximoRuta) {
      final padre = p.dirname(actual);
      if (padre == actual) break;
      actual = padre;
    }
    return actual;
  }

  /// Dart solo pone comillas a un argumento si tiene espacios. Sin comillas,
  /// el Explorador toma las comas como separadores ("100219_a,b" abre
  /// "Documentos"). El espacio final fuerza las comillas y Windows lo
  /// descarta al resolver la ruta (comprobado en la Fase 13).
  static String argumentoExplorador(String ruta) => '$ruta ';
}

Future<void> _lanzarExplorador(String argumento) =>
    Process.start('explorer.exe', [argumento], mode: ProcessStartMode.detached);
