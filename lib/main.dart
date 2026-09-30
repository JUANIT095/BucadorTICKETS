import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/almacenamiento_portable.dart';
import 'features/search/data/servicio_raiz.dart';
import 'features/search/presentation/raiz_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final rutaExe = Platform.resolvedExecutable;
  final almacenamiento = await AlmacenamientoPortable.iniciar(
    rutaExe: rutaExe,
    localAppData: Platform.environment['LOCALAPPDATA'],
  );
  final raiz = RaizController(
    servicio: ServicioRaiz(
      rutaExe: rutaExe,
      unidades: ServicioRaiz.unidadesDelSistema,
    ),
    almacenamiento: almacenamiento,
    seleccionarCarpeta: getDirectoryPath,
  );

  runApp(BuscadorTicketsApp(raiz: raiz));
  // Después de runApp: la interfaz muestra "Verificando carpeta..." mientras
  // se resuelve la raíz.
  raiz.iniciar();
}
