import '../core/constants/app_constants.dart';
import 'ticket.dart';

/// Índice persistido en `indice.json` (ARQUITECTURA §4).
class Indice {
  Indice({
    required this.raiz,
    required this.generado,
    required this.anios,
    required this.tickets,
    this.avisos = const [],
  });

  /// Raíz con la que se generó; si la raíz activa es otra, se regenera.
  final String raiz;

  final DateTime generado;

  /// Años detectados, del más reciente al más antiguo (incluye años sin
  /// tickets, para que sigan apareciendo en el filtro).
  final List<int> anios;

  final List<Ticket> tickets;

  /// Avisos de la detección (carpetas ignoradas, duplicados…), ya redactados
  /// para el usuario; se vuelven a mostrar al cargar el índice.
  final List<String> avisos;

  Map<String, dynamic> aJson() => {
    'version': AppConstants.versionIndice,
    'raiz': raiz,
    'generado': generado.toIso8601String(),
    'anios': anios,
    'avisos': avisos,
    'tickets': [for (final t in tickets) t.aJson()],
  };

  /// Null si falta, es de otra versión o los datos generales no son válidos:
  /// se trata como "sin índice". Los tickets dañados se descartan uno a uno.
  static Indice? desdeJson(Object? json) {
    if (json is! Map || json['version'] != AppConstants.versionIndice) {
      return null;
    }
    final raiz = json['raiz'];
    final generado = DateTime.tryParse('${json['generado']}');
    final anios = json['anios'];
    final avisos = json['avisos'];
    final tickets = json['tickets'];
    if (raiz is! String ||
        generado == null ||
        anios is! List ||
        tickets is! List ||
        (avisos != null && avisos is! List)) {
      return null;
    }
    return Indice(
      raiz: raiz,
      generado: generado,
      anios: [
        for (final a in anios)
          if (a is int) a,
      ],
      avisos: [
        for (final a in avisos as List? ?? const [])
          if (a is String) a,
      ],
      tickets: [for (final t in tickets) ?Ticket.desdeJson(t)],
    );
  }
}
