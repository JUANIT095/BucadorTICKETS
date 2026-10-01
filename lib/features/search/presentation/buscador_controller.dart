import 'package:flutter/foundation.dart';

import '../../../core/constants/textos.dart';
import '../../../models/carpeta_anio.dart';
import '../../../models/carpeta_mes.dart';
import '../../../models/ticket.dart';
import '../data/detector_anios.dart';
import '../data/detector_meses.dart';
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
    DateTime? fechaIndice,
    List<Ticket> tickets = const [],
    DetectorAnios detectorAnios = const DetectorAnios(),
    DetectorMeses detectorMeses = const DetectorMeses(),
  }) : _fechaIndice = fechaIndice,
       _tickets = tickets,
       _detectorAnios = detectorAnios,
       _detectorMeses = detectorMeses;

  final DateTime? _fechaIndice;
  final List<Ticket> _tickets;
  final DetectorAnios _detectorAnios;
  final DetectorMeses _detectorMeses;
  final List<String> _avisos = [];
  EstadoBusqueda _estado = const EstadoInicial();
  FiltrosBusqueda _filtros = const FiltrosBusqueda();
  List<CarpetaAnio> _carpetasAnio = const [];
  List<int> _anios = const [];
  List<CarpetaMes> _carpetasMes = const [];
  List<TicketSinMes> _ticketsSinMes = const [];

  /// Avisos generados por la última detección; se reemplazan en la siguiente.
  final Set<String> _avisosDeteccion = {};

  /// Invalida detecciones anteriores si la raíz cambia mientras se detecta.
  var _generacionDeteccion = 0;

  DateTime? get fechaIndice => _fechaIndice;
  int get totalTickets => _tickets.length;
  EstadoBusqueda get estado => _estado;
  FiltrosBusqueda get filtros => _filtros;
  List<String> get avisos => List.unmodifiable(_avisos);
  List<CarpetaAnio> get carpetasAnio => _carpetasAnio;

  /// Años detectados en la raíz, del más reciente al más antiguo.
  List<int> get anios => _anios;

  /// Meses reconocidos y carpetas no reconocidas como mes (`mes == null`).
  List<CarpetaMes> get carpetasMes => _carpetasMes;

  /// Carpetas con aspecto de ticket guardadas directamente en el año.
  List<TicketSinMes> get ticketsSinMes => _ticketsSinMes;

  /// Detecta años y meses de [raiz]; null = no hay raíz activa.
  Future<void> detectarEstructura(String? raiz) async {
    final generacion = ++_generacionDeteccion;
    _avisos.removeWhere(_avisosDeteccion.contains);
    _avisosDeteccion.clear();

    if (raiz == null) {
      _aplicarAnios(const []);
      _carpetasMes = const [];
      _ticketsSinMes = const [];
      notifyListeners();
      return;
    }

    _estado = const EstadoIndexando();
    notifyListeners();
    final anios = await _detectorAnios.detectar(raiz);
    if (generacion != _generacionDeteccion) return;

    var erroresLectura = 0;
    switch (anios) {
      case DeteccionAnios():
        _aplicarAnios(anios.carpetas);
        erroresLectura += anios.erroresLectura;
        _avisosDeAnios(anios);
      case DeteccionFallida(:final motivo):
        _aplicarAnios(const []);
        _avisoDeteccion(
          Textos.avisoDeteccionFallida(switch (motivo) {
            MotivoFalloDeteccion.noExiste => Textos.motivoNoExiste,
            MotivoFalloDeteccion.sinPermisos => Textos.motivoSinPermisos,
            MotivoFalloDeteccion.noResponde => Textos.motivoNoResponde,
          }),
        );
    }

    final meses = await _detectorMeses.detectar(_carpetasAnio);
    if (generacion != _generacionDeteccion) return;
    _carpetasMes = meses.carpetas;
    _ticketsSinMes = meses.ticketsSinMes;
    erroresLectura += meses.erroresLectura;
    _avisosDeMeses(meses);

    if (erroresLectura > 0) {
      _avisoDeteccion(Textos.avisoErroresLectura(erroresLectura));
    }
    _estado = const EstadoInicial();
    notifyListeners();
  }

  void _avisosDeAnios(DeteccionAnios anios) {
    if (anios.carpetas.isEmpty) _avisoDeteccion(Textos.sinAnios);
    for (final MapEntry(key: anio, value: nombres)
        in anios.duplicados.entries) {
      _avisoDeteccion(Textos.avisoAnioDuplicado(anio, nombres));
    }
    if (anios.ignoradas.isNotEmpty) {
      _avisoDeteccion(
        Textos.avisoCarpetasIgnoradas([
          for (final c in anios.ignoradas)
            Textos.carpetaIgnorada(
              c.nombre,
              c.motivo == MotivoIgnorada.anioFueraDeRango,
            ),
        ]),
      );
    }
  }

  void _avisosDeMeses(DeteccionMeses meses) {
    for (final MapEntry(key: (anio, mes), value: nombres)
        in meses.duplicados.entries) {
      _avisoDeteccion(Textos.avisoMesDuplicado(anio, mes, nombres));
    }
    final noReconocidas = meses.noReconocidas;
    if (noReconocidas.isNotEmpty) {
      _avisoDeteccion(
        Textos.avisoMesesNoReconocidos([
          for (final c in noReconocidas) '${c.anio}/${c.nombre}',
        ]),
      );
    }
    if (meses.ticketsSinMes.isNotEmpty) {
      _avisoDeteccion(Textos.avisoTicketsSinMes(meses.ticketsSinMes.length));
    }
    if (meses.ilegibles.isNotEmpty) {
      _avisoDeteccion(
        Textos.avisoAniosIlegibles([
          for (final i in meses.ilegibles) i.carpeta.nombre,
        ]),
      );
    }
  }

  void _aplicarAnios(List<CarpetaAnio> carpetas) {
    _carpetasAnio = carpetas;
    _anios = {for (final c in carpetas) c.anio}.toList();
    // Si el año elegido ya no existe, el filtro vuelve a "Todos".
    if (_filtros.anio != null && !_anios.contains(_filtros.anio)) {
      _filtros = _filtros.conAnio(null);
    }
  }

  void _avisoDeteccion(String mensaje) {
    _avisosDeteccion.add(mensaje);
    if (!_avisos.contains(mensaje)) _avisos.add(mensaje);
  }

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
