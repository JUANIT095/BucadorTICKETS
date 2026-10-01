// Prueba de punta a punta con la app completa y un "disco" ficticio en una
// carpeta temporal (nunca datos reales). Recorre el flujo de un usuario:
// primer uso → elegir carpeta → indexar → buscar → reabrir con el índice
// guardado → disco desconectado → reconectar y actualizar el índice.

import 'dart:io';

import 'package:buscador_tickets/app.dart';
import 'package:buscador_tickets/core/constants/app_constants.dart';
import 'package:buscador_tickets/core/constants/textos.dart';
import 'package:buscador_tickets/core/services/almacenamiento_portable.dart';
import 'package:buscador_tickets/features/search/data/repositorio_indice.dart';
import 'package:buscador_tickets/features/search/data/servicio_raiz.dart';
import 'package:buscador_tickets/features/search/presentation/raiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'helpers/entorno_prueba.dart';

final _campo = find.widgetWithText(TextField, Textos.pistaBusqueda);

void main() {
  late EntornoPrueba entorno;
  late String disco;
  late String exe;
  final controladores = <RaizController>[];

  setUp(() {
    entorno = EntornoPrueba.crear();
    disco = entorno.raiz('METADA', metada: ['2024', '2025']);
    Directory(
      p.join(disco, '2024', 'Mayo', '100219_Curación2 ABC - Proyecto IA'),
    ).createSync(recursive: true);
    // La app está en el "PC" y el disco es externo: así tiene sentido el
    // modo sin conexión (si la app estuviera dentro del USB, al desconectarlo
    // tampoco existiría la app). El caso "app dentro del USB" lo cubren las
    // pruebas de ServicioRaiz (resolución relativa al .exe).
    exe = entorno.exe(p.join('PC', 'BuscadorTickets'));
  });

  tearDown(() {
    for (final c in controladores) {
      c.dispose();
    }
    controladores.clear();
    entorno.eliminar();
  });

  /// "Abre" la app como lo haría `main`: carpeta de datos junto al .exe,
  /// resolución de la raíz e índice guardado.
  Future<void> abrirApp(
    WidgetTester tester, {
    Future<String?> Function()? seleccionar,
  }) async {
    final (raiz, repositorio) = (await tester.runAsync(() async {
      final almacenamiento = await AlmacenamientoPortable.iniciar(
        rutaExe: exe,
        localAppData: null,
      );
      final raiz = RaizController(
        servicio: ServicioRaiz(rutaExe: exe, unidades: () async => const []),
        almacenamiento: almacenamiento,
        seleccionarCarpeta: seleccionar ?? () async => null,
      );
      await raiz.iniciar();
      return (raiz, RepositorioIndice(almacenamiento));
    }))!;
    controladores.add(raiz);
    await tester.pumpWidget(
      BuscadorTicketsApp(
        key: UniqueKey(), // cada apertura es una app nueva
        raiz: raiz,
        repositorio: repositorio,
      ),
    );
    await tester.pump();
  }

  /// Espera en tiempo real (E/S e Isolate) hasta que aparezca [finder].
  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(finder, findsWidgets);
  }

  Future<void> buscar(WidgetTester tester, String texto) async {
    await tester.enterText(_campo, texto);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('flujo completo de uso', (tester) async {
    tester.view.physicalSize = const Size(1100, 750);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final indice = File(
      p.join(
        p.dirname(exe),
        AppConstants.carpetaDatos,
        AppConstants.archivoIndice,
      ),
    );

    // 1. Primer uso: pide la carpeta y la búsqueda está deshabilitada.
    await abrirApp(tester, seleccionar: () async => disco);
    expect(find.text(Textos.primerUsoTitulo), findsOneWidget);
    expect(tester.widget<TextField>(_campo).enabled, isFalse);

    // 2. Elegir la carpeta: se valida, se guarda y se indexa.
    await tester.runAsync(controladores.last.elegirCarpeta);
    await esperar(tester, find.text(Textos.ticketsIndexados(1)));
    expect(tester.widget<TextField>(_campo).enabled, isTrue);
    expect(indice.existsSync(), isTrue);

    // 3. Buscar sin tildes ni mayúsculas.
    await buscar(tester, 'CURACION');
    expect(find.text('100219_Curación2 ABC - Proyecto IA'), findsOneWidget);

    // 4. Reabrir: usa la configuración y el índice guardados (no reindexa).
    final modificado = indice.lastModifiedSync();
    await abrirApp(tester);
    await esperar(tester, find.text(Textos.ticketsIndexados(1)));
    expect(indice.lastModifiedSync(), modificado);

    // 5. Disco desconectado: busca en el último índice con aviso.
    Directory(disco).renameSync('$disco-desconectado');
    await abrirApp(tester);
    await esperar(tester, find.text(Textos.avisoSinConexion(disco)));
    await buscar(tester, '100219');
    expect(find.text('100219_Curación2 ABC - Proyecto IA'), findsOneWidget);

    // 6. Reconectar y "Actualizar índice": vuelve la raíz y se reindexa.
    Directory('$disco-desconectado').renameSync(disco);
    Directory(
      p.join(disco, '2025', 'Enero', '200001_Nuevo ticket'),
    ).createSync(recursive: true);
    final boton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, Textos.actualizarIndice),
    );
    await tester.runAsync(() async => boton.onPressed!());
    await esperar(tester, find.text(Textos.ticketsIndexados(2)));
    expect(find.text(Textos.avisoSinConexion(disco)), findsNothing);

    // El ticket nuevo ya se encuentra.
    await buscar(tester, 'nuevo');
    expect(find.text('200001_Nuevo ticket'), findsOneWidget);

    // Deja terminar el conteo real de elementos de las tarjetas (E/S con
    // tiempo límite) para no dejar temporizadores pendientes.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(seconds: 20));
  });
}
