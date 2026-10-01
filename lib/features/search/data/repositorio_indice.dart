import 'dart:convert';
import 'dart:isolate';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/almacenamiento_portable.dart';
import '../../../models/indice.dart';

sealed class CargaIndice {
  const CargaIndice();
}

class IndiceCargado extends CargaIndice {
  const IndiceCargado(this.indice);

  final Indice indice;
}

class SinIndice extends CargaIndice {
  const SinIndice();
}

/// Existe pero está dañado o es de otra versión: hay que regenerarlo.
class IndiceDanado extends CargaIndice {
  const IndiceDanado();
}

/// Carga y guarda `indice.json` en la carpeta de datos portable.
///
/// Codificar y decodificar el JSON se hace en un Isolate: con miles de
/// tickets el archivo pesa varios MB y no debe congelar la interfaz.
class RepositorioIndice {
  const RepositorioIndice(this._almacenamiento);

  final AlmacenamientoPortable _almacenamiento;

  Future<CargaIndice> cargar() async {
    final texto = await _almacenamiento.leerTexto(AppConstants.archivoIndice);
    if (texto == null) return const SinIndice();
    final indice = await Isolate.run(() => _decodificar(texto));
    return indice == null ? const IndiceDanado() : IndiceCargado(indice);
  }

  /// Devuelve false si no se pudo guardar.
  Future<bool> guardar(Indice indice) async {
    final texto = await Isolate.run(() => jsonEncode(indice.aJson()));
    return _almacenamiento.escribirTexto(AppConstants.archivoIndice, texto);
  }

  static Indice? _decodificar(String texto) {
    try {
      return Indice.desdeJson(jsonDecode(texto));
    } on FormatException {
      return null;
    }
  }
}
