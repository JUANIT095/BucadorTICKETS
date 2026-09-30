import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/textos.dart';
import '../../../core/services/almacenamiento_portable.dart';
import '../../../models/configuracion.dart';
import '../data/servicio_raiz.dart';

sealed class EstadoRaiz {
  const EstadoRaiz();
}

class RaizVerificando extends EstadoRaiz {
  const RaizVerificando();
}

/// Primer uso: todavía no hay configuración.
class RaizSinConfigurar extends EstadoRaiz {
  const RaizSinConfigurar();
}

class RaizActiva extends EstadoRaiz {
  const RaizActiva(this.ruta);

  final String ruta;
}

class RaizNoEncontrada extends EstadoRaiz {
  const RaizNoEncontrada(this.ultimaRuta, {this.coincidencias = const []});

  final String ultimaRuta;

  /// Varias → la ruta existe en más de una unidad y el usuario debe elegir.
  final List<String> coincidencias;
}

class RaizInvalida extends EstadoRaiz {
  const RaizInvalida(this.ruta, this.motivo);

  final String ruta;
  final ValidacionRaiz motivo;
}

/// Se eligió una carpeta METADA: se propone su carpeta padre.
class RaizPropuestaPadre extends EstadoRaiz {
  const RaizPropuestaPadre({required this.seleccionada, required this.padre});

  final String seleccionada;
  final String padre;
}

/// Mensaje para el usuario según el motivo por el que una carpeta no sirve.
String mensajeValidacion(ValidacionRaiz motivo) => switch (motivo) {
  RaizNoExiste() => Textos.motivoNoExiste,
  RaizSinPermisos() => Textos.motivoSinPermisos,
  RaizNoResponde() => Textos.motivoNoResponde,
  RaizSinMetada() => Textos.motivoSinMetada,
  RaizEsCarpetaMetada() || RaizValida() => '',
};

/// Estado de la carpeta raíz: selección, validación, persistencia y
/// resolución al arrancar.
///
/// Separado de [BuscadorController]: la raíz condiciona toda la pantalla y
/// la usará la indexación; así la búsqueda no depende de estos detalles.
class RaizController extends ChangeNotifier {
  RaizController({
    required ServicioRaiz servicio,
    required AlmacenamientoPortable almacenamiento,
    required Future<String?> Function() seleccionarCarpeta,
  }) : _servicio = servicio,
       _almacenamiento = almacenamiento,
       _seleccionarCarpeta = seleccionarCarpeta;

  final ServicioRaiz _servicio;
  final AlmacenamientoPortable _almacenamiento;
  final Future<String?> Function() _seleccionarCarpeta;

  EstadoRaiz _estado = const RaizVerificando();
  EstadoRaiz? _estadoPrevio;
  Configuracion? _config;
  final List<String> _avisos = [];

  EstadoRaiz get estado => _estado;
  List<String> get avisos => List.unmodifiable(_avisos);

  /// Ruta de la raíz activa; null si no hay.
  String? get rutaActiva => switch (_estado) {
    RaizActiva(:final ruta) => ruta,
    _ => null,
  };

  bool get ocupado => _estado is RaizVerificando;

  /// Resolución al arrancar: lee la configuración y busca la raíz.
  Future<void> iniciar() async {
    switch (_almacenamiento.ubicacion) {
      case UbicacionDatos.principal:
        break;
      case UbicacionDatos.respaldo:
        _agregarAviso(Textos.avisoRespaldo(_almacenamiento.carpeta!));
      case UbicacionDatos.memoria:
        _agregarAviso(Textos.avisoSoloMemoria);
    }
    _config = Configuracion.desdeJson(
      await _almacenamiento.leerJson(AppConstants.archivoConfig),
    );
    await _resolver();
  }

  Future<void> reintentar() => _resolver();

  Future<void> _resolver() async {
    _cambiar(const RaizVerificando());
    final resolucion = await _servicio.resolver(_config);
    switch (resolucion) {
      case ResolucionSinConfiguracion():
        _cambiar(const RaizSinConfigurar());
      case ResolucionEncontrada(:final ruta, :final cambioDeUbicacion):
        if (cambioDeUbicacion) {
          await _guardar(ruta);
          _agregarAviso(Textos.avisoRaizDetectada(ruta));
        }
        _cambiar(RaizActiva(ruta));
      case ResolucionNoEncontrada(:final ultimaRuta, :final coincidencias):
        _cambiar(RaizNoEncontrada(ultimaRuta, coincidencias: coincidencias));
    }
  }

  /// Abre el selector de carpeta. Cancelar el diálogo no cambia nada.
  Future<void> elegirCarpeta() async {
    final ruta = await _seleccionarCarpeta();
    if (ruta == null) return;
    await _probar(ruta);
  }

  /// Acepta la carpeta padre propuesta.
  Future<void> usarPadre() async {
    if (_estado case RaizPropuestaPadre(:final padre)) await _probar(padre);
  }

  /// Descarta la propuesta y vuelve al estado anterior (p. ej. la raíz activa).
  void cancelarPropuesta() {
    if (_estado is! RaizPropuestaPadre) return;
    _cambiar(_estadoPrevio ?? const RaizSinConfigurar());
  }

  Future<void> _probar(String ruta) async {
    final anterior = _estado is RaizPropuestaPadre ? _estadoPrevio : _estado;
    _cambiar(const RaizVerificando());
    final validacion = await _servicio.validar(ruta);
    switch (validacion) {
      case RaizValida(:final ruta):
        await _guardar(ruta);
        _cambiar(RaizActiva(ruta));
      case RaizEsCarpetaMetada(:final padre):
        _estadoPrevio = anterior;
        _cambiar(RaizPropuestaPadre(seleccionada: ruta, padre: padre));
      default:
        if (anterior is RaizActiva) {
          // Una mala selección no deja al usuario sin la raíz que funcionaba.
          _agregarAviso(
            Textos.avisoCarpetaNoValida(mensajeValidacion(validacion)),
          );
          _cambiar(anterior);
        } else {
          _cambiar(RaizInvalida(ruta, validacion));
        }
    }
  }

  Future<void> _guardar(String ruta) async {
    _config = _servicio.configuracionPara(ruta);
    final guardado = await _almacenamiento.escribirJson(
      AppConstants.archivoConfig,
      _config!.aJson(),
    );
    if (!guardado) _agregarAviso(Textos.avisoConfigNoGuardada);
  }

  void descartarAviso(String mensaje) {
    if (_avisos.remove(mensaje)) notifyListeners();
  }

  void _agregarAviso(String mensaje) {
    if (!_avisos.contains(mensaje)) _avisos.add(mensaje);
  }

  void _cambiar(EstadoRaiz estado) {
    _estado = estado;
    notifyListeners();
  }
}
