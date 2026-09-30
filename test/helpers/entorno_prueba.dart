import 'dart:io';

import 'package:buscador_tickets/core/constants/app_constants.dart';
import 'package:buscador_tickets/core/services/almacenamiento_portable.dart';
import 'package:buscador_tickets/features/search/data/servicio_raiz.dart';
import 'package:buscador_tickets/features/search/presentation/raiz_controller.dart';
import 'package:buscador_tickets/models/configuracion.dart';
import 'package:path/path.dart' as p;

/// Crea e inicia un [RaizController] sobre el [entorno]. Hace E/S real: en
/// pruebas de widget, llamarlo dentro de `tester.runAsync`.
Future<RaizController> crearRaizController(
  EntornoPrueba entorno, {
  String? raizGuardada,
  Future<String?> Function()? seleccionarCarpeta,
}) async {
  final exe = entorno.exe();
  final almacenamiento = await AlmacenamientoPortable.iniciar(
    rutaExe: exe,
    localAppData: null,
  );
  if (raizGuardada != null) {
    await almacenamiento.escribirJson(
      AppConstants.archivoConfig,
      Configuracion(raiz: raizGuardada).aJson(),
    );
  }
  final raiz = RaizController(
    servicio: ServicioRaiz(rutaExe: exe, unidades: () async => const []),
    almacenamiento: almacenamiento,
    seleccionarCarpeta: seleccionarCarpeta ?? () async => null,
  );
  await raiz.iniciar();
  return raiz;
}

/// Carpetas ficticias en un directorio temporal. Nunca toca datos reales.
class EntornoPrueba {
  EntornoPrueba._(this.base);

  factory EntornoPrueba.crear() =>
      EntornoPrueba._(Directory.systemTemp.createTempSync('buscador_prueba_'));

  final Directory base;

  String ruta(String relativa) => p.join(base.path, relativa);

  /// Ruta de un .exe ficticio; crea su carpeta.
  String exe([String carpeta = 'App']) {
    Directory(ruta(carpeta)).createSync(recursive: true);
    return p.join(ruta(carpeta), 'BuscadorTickets.exe');
  }

  /// Crea una raíz con las carpetas METADA indicadas y devuelve su ruta.
  String raiz(String relativa, {List<String> metada = const ['METADA 2024']}) {
    final carpeta = ruta(relativa);
    Directory(carpeta).createSync(recursive: true);
    for (final nombre in metada) {
      Directory(p.join(carpeta, nombre)).createSync();
    }
    return carpeta;
  }

  void eliminar() {
    if (base.existsSync()) base.deleteSync(recursive: true);
  }
}
