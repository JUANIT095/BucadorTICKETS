import 'package:flutter/foundation.dart';

import '../../../models/ticket.dart';
import '../domain/filtros_busqueda.dart';

sealed class EstadoBusqueda {
  const EstadoBusqueda();
}

class EstadoInicial extends EstadoBusqueda {
  const EstadoInicial();
}

class EstadoBuscando extends EstadoBusqueda {
  const EstadoBuscando();
}

class EstadoIndexando extends EstadoBusqueda {
  const EstadoIndexando();
}

class EstadoSinResultados extends EstadoBusqueda {
  const EstadoSinResultados();
}

class EstadoConResultados extends EstadoBusqueda {
  const EstadoConResultados(this.tickets);

  final List<Ticket> tickets;
}

class EstadoError extends EstadoBusqueda {
  const EstadoError(this.mensaje);

  /// Mensaje ya redactado para el usuario final.
  final String mensaje;
}

/// Estado de la pantalla de búsqueda.
class BuscadorController extends ChangeNotifier {
  BuscadorController({
    String? raiz,
    DateTime? fechaIndice,
    List<Ticket> tickets = const [],
  }) : _raiz = raiz,
       _fechaIndice = fechaIndice,
       _tickets = tickets;

  final String? _raiz;
  final DateTime? _fechaIndice;
  final List<Ticket> _tickets;
  final List<String> _avisos = [];
  EstadoBusqueda _estado = const EstadoInicial();
  FiltrosBusqueda _filtros = const FiltrosBusqueda();

  String? get raiz => _raiz;
  DateTime? get fechaIndice => _fechaIndice;
  int get totalTickets => _tickets.length;
  EstadoBusqueda get estado => _estado;
  FiltrosBusqueda get filtros => _filtros;
  List<String> get avisos => List.unmodifiable(_avisos);

  /// Años presentes en el índice, del más reciente al más antiguo.
  List<int> get anios =>
      {for (final t in _tickets) t.anio}.toList()..sort((a, b) => b - a);

  void buscar(String texto) {
    // TEMPORAL (Fase 11): sin motor de búsqueda, cualquier consulta
    // devuelve todos los tickets cargados.
    if (texto.trim().isEmpty) {
      _estado = const EstadoInicial();
    } else if (_tickets.isEmpty) {
      _estado = const EstadoSinResultados();
    } else {
      _estado = EstadoConResultados(_tickets);
    }
    notifyListeners();
  }

  void cambiarFiltros(FiltrosBusqueda filtros) {
    _filtros = filtros;
    notifyListeners();
  }

  void mostrarAviso(String mensaje) {
    if (_avisos.contains(mensaje)) return;
    _avisos.add(mensaje);
    notifyListeners();
  }

  void descartarAviso(String mensaje) {
    if (_avisos.remove(mensaje)) notifyListeners();
  }

  /// TEMPORAL (Fase 12): solo lo usa el selector de estados de demostración.
  void mostrarEstado(EstadoBusqueda estado) {
    _estado = estado;
    notifyListeners();
  }
}
