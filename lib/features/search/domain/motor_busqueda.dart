import '../../../core/constants/app_constants.dart';
import '../../../core/utils/normalizador.dart';
import '../../../models/ticket.dart';
import 'filtros_busqueda.dart';

class ResultadoBusqueda {
  const ResultadoBusqueda(this.tickets, {required this.total});

  /// Tickets ordenados por relevancia, como máximo [MotorBusqueda.limite].
  final List<Ticket> tickets;

  /// Coincidencias totales antes de aplicar el límite.
  final int total;

  bool get limitado => total > tickets.length;
}

/// Puntuación por regla (ARQUITECTURA §5, prioridad de la sección 8).
abstract final class Puntos {
  /// Número exacto o nombre de carpeta completo.
  static const exacto = 1000;
  static const numeroEmpieza = 900;
  static const numeroContiene = 800;
  static const nombreEmpieza = 700;
  static const nombreContiene = 500;

  /// Todas las palabras de la consulta aparecen, en cualquier orden.
  static const palabrasClave = 300;
}

/// Filtra, puntúa y ordena tickets. Sin estado ni E/S: se ejecuta en el hilo
/// principal porque usa los campos ya normalizados de cada ticket (unos
/// pocos milisegundos incluso con decenas de miles de tickets).
class MotorBusqueda {
  const MotorBusqueda({this.limite = AppConstants.limiteResultados});

  final int limite;

  ResultadoBusqueda buscar(
    List<Ticket> tickets,
    String consulta,
    FiltrosBusqueda filtros,
  ) {
    final q = normalizar(consulta);
    if (q.isEmpty) return const ResultadoBusqueda([], total: 0);
    final palabras = palabrasNormalizadas(consulta);

    final puntuados = <(Ticket, int)>[
      for (final t in tickets)
        if (_pasaFiltros(t, filtros))
          if (puntuar(t, q, palabras) case final p when p > 0) (t, p),
    ];
    puntuados.sort(_comparar);

    return ResultadoBusqueda([
      for (final (t, _) in puntuados.take(limite)) t,
    ], total: puntuados.length);
  }

  static bool _pasaFiltros(Ticket t, FiltrosBusqueda f) =>
      (f.anio == null || t.anio == f.anio) && (f.mes == null || t.mes == f.mes);

  /// Mayor puntuación que alcanza [t] para la consulta normalizada [q] y sus
  /// [palabras]; 0 = no coincide.
  static int puntuar(Ticket t, String q, List<String> palabras) {
    final numero = t.numeroNorm;
    if ((numero.isNotEmpty && numero == q) || t.carpetaNorm == q) {
      return Puntos.exacto;
    }
    if (numero.isNotEmpty) {
      if (numero.startsWith(q)) return Puntos.numeroEmpieza;
      if (numero.contains(q)) return Puntos.numeroContiene;
    }
    if (t.nombreNorm.startsWith(q) || t.carpetaNorm.startsWith(q)) {
      return Puntos.nombreEmpieza;
    }
    if (t.nombreNorm.contains(q) || t.carpetaNorm.contains(q)) {
      return Puntos.nombreContiene;
    }
    if (palabras.length > 1 && palabras.every(t.carpetaNorm.contains)) {
      return Puntos.palabrasClave;
    }
    return 0;
  }

  /// Más puntos primero; a igualdad: año desc, mes desc (sin mes al final),
  /// número asc (sin número al final) y nombre de carpeta.
  static int _comparar((Ticket, int) a, (Ticket, int) b) {
    final (ta, pa) = a;
    final (tb, pb) = b;
    if (pa != pb) return pb.compareTo(pa);
    if (ta.anio != tb.anio) return tb.anio.compareTo(ta.anio);
    final porMes = (tb.mes ?? 0).compareTo(ta.mes ?? 0);
    if (porMes != 0) return porMes;
    final porNumero = _compararNumeros(ta.numero, tb.numero);
    if (porNumero != 0) return porNumero;
    return ta.carpetaNorm.compareTo(tb.carpetaNorm);
  }

  /// Orden numérico sin convertir a entero (los números pueden ser largos o
  /// tener ceros a la izquierda): primero por longitud sin ceros iniciales.
  static int _compararNumeros(String? a, String? b) {
    if (a == null || b == null) return a == b ? 0 : (a == null ? 1 : -1);
    final sa = a.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final sb = b.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (sa.length != sb.length) return sa.length.compareTo(sb.length);
    return sa.compareTo(sb);
  }
}
