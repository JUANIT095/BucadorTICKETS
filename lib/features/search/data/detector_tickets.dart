import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/constants/app_constants.dart';
import '../../../models/carpeta_mes.dart';
import '../../../models/ticket.dart';
import 'detector_meses.dart';
import 'parser_carpetas.dart';

/// Carpeta de mes que no se pudo leer; las demás se procesan igual.
class CarpetaMesIlegible {
  const CarpetaMesIlegible(this.carpeta, {required this.porTiempo});

  final CarpetaMes carpeta;

  /// true = no respondió a tiempo; false = sin permisos o error de lectura.
  final bool porTiempo;
}

class DeteccionTickets {
  const DeteccionTickets({
    required this.tickets,
    this.ilegibles = const [],
    this.erroresLectura = 0,
  });

  /// Orden: año desc, mes asc (sin mes al final), nombre de carpeta.
  final List<Ticket> tickets;

  final List<CarpetaMesIlegible> ilegibles;

  /// Entradas sueltas que no se pudieron leer.
  final int erroresLectura;
}

/// Detecta las carpetas de ticket dentro de cada carpeta de mes (incluidas
/// las no reconocidas como mes) y convierte en tickets las carpetas con
/// aspecto de ticket guardadas directamente en el año. Solo lectura; no entra
/// en el contenido de los tickets.
///
/// Sin Isolate todavía: E/S asíncrona, un listado por mes. La indexación
/// (Fase 10) ejecutará el recorrido completo en un Isolate.
class DetectorTickets {
  const DetectorTickets({this.limitePorMes = AppConstants.limiteValidacion});

  final Duration limitePorMes;

  Future<DeteccionTickets> detectar(String raiz, DeteccionMeses meses) async {
    final porMes = await Future.wait(
      meses.carpetas.map((m) => _detectarEnMes(raiz, m)),
    );

    final tickets = <Ticket>[
      for (final suelto in meses.ticketsSinMes)
        _ticket(
          raiz,
          nombreCarpeta: suelto.nombre,
          ruta: suelto.ruta,
          anio: suelto.anio,
          mes: null,
          carpetaMes: '',
        ),
    ];
    final ilegibles = <CarpetaMesIlegible>[];
    var errores = 0;
    for (final r in porMes) {
      tickets.addAll(r.tickets);
      ilegibles.addAll(r.ilegibles);
      errores += r.erroresLectura;
    }

    tickets.sort((a, b) {
      final porAnio = b.anio.compareTo(a.anio);
      if (porAnio != 0) return porAnio;
      final porMesAsc = (a.mes ?? 13).compareTo(b.mes ?? 13);
      if (porMesAsc != 0) return porMesAsc;
      return a.nombreCarpeta.compareTo(b.nombreCarpeta);
    });
    return DeteccionTickets(
      tickets: tickets,
      ilegibles: ilegibles,
      erroresLectura: errores,
    );
  }

  Future<DeteccionTickets> _detectarEnMes(String raiz, CarpetaMes mes) async {
    try {
      return await _listar(raiz, mes).timeout(limitePorMes);
    } on TimeoutException {
      return DeteccionTickets(
        tickets: const [],
        ilegibles: [CarpetaMesIlegible(mes, porTiempo: true)],
      );
    } on FileSystemException {
      return DeteccionTickets(
        tickets: const [],
        ilegibles: [CarpetaMesIlegible(mes, porTiempo: false)],
      );
    }
  }

  Future<DeteccionTickets> _listar(String raiz, CarpetaMes mes) async {
    final tickets = <Ticket>[];
    var errores = 0;

    final entradas = Directory(mes.ruta).list(followLinks: false).handleError((
      Object error,
    ) {
      // Si falla la propia carpeta del mes, el mes entero es ilegible.
      if (errorDeLaCarpeta(error, mes.ruta)) throw error;
      errores++;
    }, test: (e) => e is FileSystemException);
    await for (final entrada in entradas) {
      if (entrada is! Directory) continue;
      tickets.add(
        _ticket(
          raiz,
          nombreCarpeta: p.basename(entrada.path),
          ruta: entrada.path,
          anio: mes.anio,
          mes: mes.mes,
          carpetaMes: mes.nombre,
        ),
      );
    }
    return DeteccionTickets(tickets: tickets, erroresLectura: errores);
  }

  Ticket _ticket(
    String raiz, {
    required String nombreCarpeta,
    required String ruta,
    required int anio,
    required int? mes,
    required String carpetaMes,
  }) {
    final (:numero, :nombre) = numeroYNombreDeTicket(nombreCarpeta);
    return Ticket(
      numero: numero,
      nombre: nombre,
      nombreCarpeta: nombreCarpeta,
      anio: anio,
      mes: mes,
      carpetaMes: carpetaMes,
      rutaRelativa: p.relative(ruta, from: raiz),
    );
  }
}
