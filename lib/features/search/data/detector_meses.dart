import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/meses.dart';
import '../../../models/carpeta_anio.dart';
import '../../../models/carpeta_mes.dart';
import 'parser_carpetas.dart';

/// Carpeta con aspecto de ticket directamente dentro del año (sin mes). Se
/// registra aquí; la detección de tickets (Fase 8) decide cómo incluirla.
class TicketSinMes {
  const TicketSinMes({
    required this.anio,
    required this.nombre,
    required this.ruta,
  });

  final int anio;
  final String nombre;
  final String ruta;
}

/// Carpeta de año que no se pudo leer; las demás se procesan igual.
class CarpetaAnioIlegible {
  const CarpetaAnioIlegible(this.carpeta, {required this.porTiempo});

  final CarpetaAnio carpeta;

  /// true = no respondió a tiempo; false = sin permisos o error de lectura.
  final bool porTiempo;
}

class DeteccionMeses {
  const DeteccionMeses({
    required this.carpetas,
    this.ticketsSinMes = const [],
    this.ilegibles = const [],
    this.erroresLectura = 0,
  });

  /// Meses reconocidos y carpetas no reconocidas como mes (`mes == null`).
  /// Orden: año desc, mes asc (no reconocidas al final), nombre.
  final List<CarpetaMes> carpetas;

  final List<TicketSinMes> ticketsSinMes;
  final List<CarpetaAnioIlegible> ilegibles;

  /// Entradas sueltas que no se pudieron leer.
  final int erroresLectura;

  List<CarpetaMes> get reconocidas => [
    for (final c in carpetas)
      if (c.reconocida) c,
  ];

  List<CarpetaMes> get noReconocidas => [
    for (final c in carpetas)
      if (!c.reconocida) c,
  ];

  /// Meses con más de una carpeta en el mismo año ("Mayo" y "05 Mayo"):
  /// clave `(año, mes)`, valor nombres.
  Map<(int, int), List<String>> get duplicados {
    final porMes = <(int, int), List<String>>{};
    for (final c in reconocidas) {
      (porMes[(c.anio, c.mes!)] ??= []).add(c.nombre);
    }
    return {
      for (final MapEntry(key: clave, value: nombres) in porMes.entries)
        if (nombres.length > 1) clave: nombres,
    };
  }
}

/// Detecta las carpetas de mes dentro de cada carpeta de año. Solo lectura;
/// no entra en los tickets.
///
/// Reglas (ARQUITECTURA §9): 1) ¿mes? → mes; 2) ¿parece ticket? → ticket sin
/// mes; 3) si no → carpeta no reconocida, cuyos tickets se incluyen igual.
/// Sin Isolate: un listado por año, en paralelo y asíncrono.
class DetectorMeses {
  const DetectorMeses({this.limitePorAnio = AppConstants.limiteValidacion});

  final Duration limitePorAnio;

  Future<DeteccionMeses> detectar(List<CarpetaAnio> anios) async {
    final porAnio = await Future.wait(anios.map(_detectarEnAnio));

    final carpetas = <CarpetaMes>[];
    final ticketsSinMes = <TicketSinMes>[];
    final ilegibles = <CarpetaAnioIlegible>[];
    var errores = 0;
    for (final r in porAnio) {
      carpetas.addAll(r.carpetas);
      ticketsSinMes.addAll(r.ticketsSinMes);
      ilegibles.addAll(r.ilegibles);
      errores += r.erroresLectura;
    }

    carpetas.sort((a, b) {
      final porAnioDesc = b.anio.compareTo(a.anio);
      if (porAnioDesc != 0) return porAnioDesc;
      final porMes = (a.mes ?? 13).compareTo(b.mes ?? 13);
      return porMes != 0 ? porMes : a.nombre.compareTo(b.nombre);
    });
    ticketsSinMes.sort((a, b) => a.ruta.compareTo(b.ruta));
    return DeteccionMeses(
      carpetas: carpetas,
      ticketsSinMes: ticketsSinMes,
      ilegibles: ilegibles,
      erroresLectura: errores,
    );
  }

  Future<DeteccionMeses> _detectarEnAnio(CarpetaAnio anio) async {
    try {
      return await _listar(anio).timeout(limitePorAnio);
    } on TimeoutException {
      return DeteccionMeses(
        carpetas: const [],
        ilegibles: [CarpetaAnioIlegible(anio, porTiempo: true)],
      );
    } on FileSystemException {
      return DeteccionMeses(
        carpetas: const [],
        ilegibles: [CarpetaAnioIlegible(anio, porTiempo: false)],
      );
    }
  }

  Future<DeteccionMeses> _listar(CarpetaAnio anio) async {
    final carpetas = <CarpetaMes>[];
    final ticketsSinMes = <TicketSinMes>[];
    var errores = 0;

    final entradas = Directory(anio.ruta).list(followLinks: false).handleError((
      Object error,
    ) {
      // Si falla la propia carpeta del año, el año entero es ilegible.
      if (errorDeLaCarpeta(error, anio.ruta)) throw error;
      errores++;
    }, test: (e) => e is FileSystemException);
    await for (final entrada in entradas) {
      if (entrada is! Directory) continue;
      final nombre = p.basename(entrada.path);
      final mes = mesDeCarpeta(nombre);
      if (mes == null && pareceTicket(nombre)) {
        ticketsSinMes.add(
          TicketSinMes(anio: anio.anio, nombre: nombre, ruta: entrada.path),
        );
      } else {
        carpetas.add(
          CarpetaMes(
            anio: anio.anio,
            mes: mes,
            nombre: nombre,
            ruta: entrada.path,
          ),
        );
      }
    }
    return DeteccionMeses(
      carpetas: carpetas,
      ticketsSinMes: ticketsSinMes,
      erroresLectura: errores,
    );
  }
}
