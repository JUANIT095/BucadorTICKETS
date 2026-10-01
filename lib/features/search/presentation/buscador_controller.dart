import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/textos.dart';
import '../../../core/services/acciones_sistema.dart';
import '../../../models/indice.dart';
import '../../../models/ticket.dart';
import '../data/contador_elementos.dart';
import '../data/escaner_directorios.dart';
import '../data/repositorio_indice.dart';
import '../domain/filtros_busqueda.dart';
import '../domain/motor_busqueda.dart';

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
  const EstadoConResultados(this.tickets, {int? total})
    : total = total ?? tickets.length;

  /// Resultados mostrados (como máximo el límite).
  final List<Ticket> tickets;

  /// Coincidencias totales; mayor que `tickets.length` si se recortó.
  final int total;
}

class EstadoError extends EstadoBusqueda {
  const EstadoError(this.mensaje);

  /// Mensaje ya redactado para el usuario final.
  final String mensaje;
}

/// Genera el índice de una raíz. Por defecto, en un Isolate.
typedef Escaner = Future<Indice> Function(String raiz);

/// Cuenta los elementos de la carpeta de un ticket (ruta absoluta).
typedef ContadorElementos = Future<int?> Function(String ruta);

/// Abre una carpeta en el Explorador (ruta absoluta del ticket y raíz).
typedef AbrirCarpeta =
    Future<ResultadoAbrir> Function(String ruta, {required String raiz});

Future<Indice> _escanearEnIsolate(String raiz) =>
    Isolate.run(() => escanearRaiz(raiz));

/// Estado de la pantalla de búsqueda y del índice.
class BuscadorController extends ChangeNotifier {
  BuscadorController({
    DateTime? fechaIndice,
    List<Ticket> tickets = const [],
    RepositorioIndice? repositorio,
    Escaner escaner = _escanearEnIsolate,
    MotorBusqueda motor = const MotorBusqueda(),
    ContadorElementos contador = contarElementos,
    AbrirCarpeta? abrir,
  }) : _fechaIndice = fechaIndice,
       _tickets = tickets,
       _repositorio = repositorio,
       _escaner = escaner,
       _motor = motor,
       _contador = contador,
       _abrir = abrir ?? const AccionesSistema().abrirCarpeta;

  /// Null = sin persistencia (p. ej. en pruebas): siempre se indexa.
  final RepositorioIndice? _repositorio;
  final Escaner _escaner;
  final MotorBusqueda _motor;
  final ContadorElementos _contador;
  final AbrirCarpeta _abrir;

  /// Conteos ya pedidos en esta sesión, por ruta absoluta.
  final Map<String, Future<int?>> _elementos = {};

  DateTime? _fechaIndice;
  List<Ticket> _tickets;
  List<int> _anios = const [];
  final List<String> _avisos = [];
  EstadoBusqueda _estado = const EstadoInicial();
  FiltrosBusqueda _filtros = const FiltrosBusqueda();
  var _indexando = false;
  var _sinConexion = false;

  /// Avisos que vienen del índice (y de su carga); se reemplazan al aplicar
  /// otro índice.
  final Set<String> _avisosIndice = {};

  /// Invalida operaciones anteriores si la raíz cambia mientras se indexa.
  var _generacion = 0;

  DateTime? get fechaIndice => _fechaIndice;
  int get totalTickets => _tickets.length;
  List<Ticket> get tickets => _tickets;
  EstadoBusqueda get estado => _estado;
  FiltrosBusqueda get filtros => _filtros;
  List<String> get avisos => List.unmodifiable(_avisos);

  /// Años del índice, del más reciente al más antiguo.
  List<int> get anios => _anios;

  bool get indexando => _indexando;

  /// La raíz no está disponible y se busca en el último índice guardado.
  bool get sinConexion => _sinConexion;

  /// Raíz activa: usa el índice guardado si es de esta raíz; si no hay, está
  /// dañado o es de otra raíz, indexa.
  Future<void> activarRaiz(String raiz) async {
    final generacion = ++_generacion;
    _sinConexion = false;
    final carga = await _cargarGuardado();
    if (generacion != _generacion) return;
    if (carga case IndiceCargado(
      :final indice,
    ) when p.equals(indice.raiz, raiz)) {
      _aplicar(indice);
      notifyListeners();
      return;
    }
    await _indexar(raiz, generacion, indiceDanado: carga is IndiceDanado);
  }

  /// Botón "Actualizar índice": vuelve a recorrer la raíz.
  Future<void> actualizarIndice(String raiz) => _indexar(raiz, ++_generacion);

  /// La raíz no está disponible: si hay un índice guardado de esa raíz, se
  /// puede buscar en él con aviso.
  Future<void> cargarSinConexion(String ultimaRuta) async {
    final generacion = ++_generacion;
    final carga = await _cargarGuardado();
    if (generacion != _generacion) return;
    _indexando = false;
    if (carga case IndiceCargado(
      :final indice,
    ) when p.equals(indice.raiz, ultimaRuta)) {
      _sinConexion = true;
      _aplicar(indice, extras: [Textos.avisoSinConexion(ultimaRuta)]);
    } else {
      _sinConexion = false;
      _aplicar(null);
    }
    notifyListeners();
  }

  /// Sin raíz (primer uso, carpeta inválida…): se vacía el índice en memoria.
  void desactivar() {
    _generacion++;
    _indexando = false;
    _sinConexion = false;
    _aplicar(null);
    notifyListeners();
  }

  Future<CargaIndice> _cargarGuardado() async =>
      await _repositorio?.cargar() ?? const SinIndice();

  Future<void> _indexar(
    String raiz,
    int generacion, {
    bool indiceDanado = false,
  }) async {
    _indexando = true;
    _sinConexion = false;
    _estado = const EstadoIndexando();
    notifyListeners();

    final Indice indice;
    try {
      indice = await _escaner(raiz);
    } catch (_) {
      // Fallo inesperado del recorrido: mensaje claro, sin detalles técnicos.
      if (generacion != _generacion) return;
      _indexando = false;
      _estado = const EstadoError(Textos.errorIndexar);
      notifyListeners();
      return;
    }
    if (generacion != _generacion) return;
    final guardado = await _repositorio?.guardar(indice) ?? true;
    if (generacion != _generacion) return;

    _indexando = false;
    _aplicar(
      indice,
      extras: [
        if (indiceDanado) Textos.avisoIndiceRegenerado,
        if (!guardado) Textos.avisoIndiceNoGuardado,
      ],
    );
    notifyListeners();
  }

  /// Carga [indice] en memoria (null = vacío). Los resultados anteriores ya
  /// no valen, así que la pantalla vuelve al estado inicial.
  void _aplicar(Indice? indice, {List<String> extras = const []}) {
    _tickets = indice?.tickets ?? const [];
    _elementos.clear(); // otro índice: los conteos pueden haber cambiado
    _anios = indice?.anios ?? const [];
    _fechaIndice = indice?.generado;
    // Si el año elegido ya no existe, el filtro vuelve a "Todos".
    if (_filtros.anio != null && !_anios.contains(_filtros.anio)) {
      _filtros = _filtros.conAnio(null);
    }
    _avisos.removeWhere(_avisosIndice.contains);
    _avisosIndice.clear();
    for (final aviso in [...?indice?.avisos, ...extras]) {
      _avisosIndice.add(aviso);
      if (!_avisos.contains(aviso)) _avisos.add(aviso);
    }
    _estado = const EstadoInicial();
  }

  /// "Abrir carpeta": abre el ticket en el Explorador de Windows.
  Future<ResultadoAbrir> abrirCarpeta(Ticket ticket, String raiz) =>
      _abrir(ticket.rutaEn(raiz), raiz: raiz);

  /// Elementos de la carpeta de [ticket] bajo [raiz]. Se cuenta la primera vez
  /// que se pide (al construirse la tarjeta, es decir, solo para las tarjetas
  /// visibles) y se recuerda durante la sesión; null = no disponible.
  Future<int?> elementosDe(Ticket ticket, String raiz) {
    final ruta = ticket.rutaEn(raiz);
    return _elementos[ruta] ??= _contador(ruta);
  }

  /// Busca en el índice cargado aplicando los filtros actuales.
  void buscar(String texto) {
    if (texto.trim().isEmpty) {
      _estado = const EstadoInicial();
    } else {
      final resultado = _motor.buscar(_tickets, texto, _filtros);
      _estado = resultado.tickets.isEmpty
          ? const EstadoSinResultados()
          : EstadoConResultados(resultado.tickets, total: resultado.total);
    }
    notifyListeners();
  }

  void cambiarFiltros(FiltrosBusqueda filtros) {
    _filtros = filtros;
    notifyListeners();
  }

  @visibleForTesting
  void mostrarAviso(String mensaje) {
    if (_avisos.contains(mensaje)) return;
    _avisos.add(mensaje);
    notifyListeners();
  }

  void descartarAviso(String mensaje) {
    if (_avisos.remove(mensaje)) notifyListeners();
  }

  /// Para revisar cada estado en las pruebas de widget.
  @visibleForTesting
  void mostrarEstado(EstadoBusqueda estado) {
    _estado = estado;
    notifyListeners();
  }
}
