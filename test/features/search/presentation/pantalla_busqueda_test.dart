import 'package:buscador_tickets/core/constants/textos.dart';
import 'package:buscador_tickets/core/theme/app_theme.dart';
import 'package:buscador_tickets/features/search/presentation/buscador_controller.dart';
import 'package:buscador_tickets/features/search/presentation/datos_demo.dart';
import 'package:buscador_tickets/features/search/presentation/pantalla_busqueda.dart';
import 'package:buscador_tickets/features/search/presentation/raiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/entorno_prueba.dart';

final campoBusqueda = find.widgetWithText(TextField, Textos.pistaBusqueda);

void main() {
  late EntornoPrueba entorno;
  late BuscadorController controller;
  late RaizController raiz;
  late String rutaRaiz;

  setUp(() {
    entorno = EntornoPrueba.crear();
    rutaRaiz = entorno.raiz('DISCO');
    controller = BuscadorController(
      fechaIndice: DatosDemo.fechaIndice,
      tickets: DatosDemo.tickets,
    );
  });

  tearDown(() {
    controller.dispose();
    raiz.dispose();
    entorno.eliminar();
  });

  /// Monta la pantalla con el área útil de la ventana en su tamaño mínimo
  /// (800x600 menos bordes y barra de título); un desborde hace fallar la prueba.
  /// Por defecto hay una raíz válida guardada.
  Future<void> montar(
    WidgetTester tester, {
    String? raizGuardada,
    bool sinConfiguracion = false,
    Future<String?> Function()? seleccionarCarpeta,
  }) async {
    tester.view.physicalSize = const Size(784, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    raiz = (await tester.runAsync(
      () => crearRaizController(
        entorno,
        raizGuardada: sinConfiguracion ? null : raizGuardada ?? rutaRaiz,
        seleccionarCarpeta: seleccionarCarpeta,
      ),
    ))!;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.oscuro,
        home: PantallaBusqueda(controller: controller, raiz: raiz),
      ),
    );
  }

  bool campoHabilitado(WidgetTester tester) =>
      tester.widget<TextField>(campoBusqueda).enabled ?? true;

  Future<void> mostrar(WidgetTester tester, EstadoBusqueda estado) async {
    controller.mostrarEstado(estado);
    await tester.pump();
  }

  testWidgets('Estado inicial', (tester) async {
    await montar(tester);
    expect(find.text(Textos.estadoInicial), findsOneWidget);
  });

  testWidgets('Estado buscando', (tester) async {
    await montar(tester);
    await mostrar(tester, const EstadoBuscando());
    expect(find.text(Textos.estadoBuscando), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Estado indexando', (tester) async {
    await montar(tester);
    await mostrar(tester, const EstadoIndexando());
    expect(find.text(Textos.estadoIndexando), findsOneWidget);
  });

  testWidgets('Estado sin resultados', (tester) async {
    await montar(tester);
    await mostrar(tester, const EstadoSinResultados());
    expect(find.text(Textos.sinResultados), findsOneWidget);
    expect(find.text(Textos.sinResultadosDetalle), findsOneWidget);
  });

  testWidgets('Estado de error muestra el mensaje', (tester) async {
    await montar(tester);
    await mostrar(tester, const EstadoError(Textos.errorLeerIndice));
    expect(find.text(Textos.estadoError), findsOneWidget);
    expect(find.text(Textos.errorLeerIndice), findsOneWidget);
  });

  testWidgets('Estado con resultados muestra tarjetas y acciones', (
    tester,
  ) async {
    await montar(tester);
    await mostrar(tester, const EstadoConResultados(DatosDemo.tickets));
    expect(find.text(Textos.resultados(5)), findsOneWidget);
    expect(find.text('100219_Curación2 ABC - Proyecto IA'), findsOneWidget);
    expect(find.text(Textos.abrirCarpeta), findsWidgets);
    expect(find.text(Textos.copiarRuta), findsWidgets);
  });

  testWidgets('Enter busca y mantiene el foco en el campo', (tester) async {
    await montar(tester);
    await tester.enterText(campoBusqueda, 'curacion');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(find.text('100219_Curación2 ABC - Proyecto IA'), findsOneWidget);
    final campo = tester.widget<EditableText>(
      find.descendant(of: campoBusqueda, matching: find.byType(EditableText)),
    );
    expect(campo.focusNode.hasFocus, isTrue);
  });

  testWidgets('El aviso se muestra y se puede cerrar', (tester) async {
    await montar(tester);
    controller.mostrarAviso(Textos.avisoRaizNoDisponible);
    await tester.pump();
    expect(find.text(Textos.avisoRaizNoDisponible), findsOneWidget);

    await tester.tap(find.byTooltip(Textos.cerrarAviso));
    await tester.pump();
    expect(find.text(Textos.avisoRaizNoDisponible), findsNothing);
  });

  testWidgets('Encabezado y pie muestran raíz, fecha y total', (tester) async {
    await montar(tester);
    expect(find.text(rutaRaiz), findsOneWidget);
    expect(find.text(Textos.cambiarCarpeta), findsOneWidget);
    expect(find.text(Textos.actualizarIndice), findsOneWidget);
    expect(
      find.text(Textos.indiceActualizado(DatosDemo.fechaIndice)),
      findsOneWidget,
    );
    expect(find.text(Textos.ticketsIndexados(5)), findsOneWidget);
  });

  group('Carpeta raíz', () {
    testWidgets('Primer uso: pide la carpeta y deshabilita la búsqueda', (
      tester,
    ) async {
      var vecesSelector = 0;
      await montar(
        tester,
        sinConfiguracion: true,
        seleccionarCarpeta: () async {
          vecesSelector++;
          return null;
        },
      );

      expect(find.text(Textos.primerUsoTitulo), findsOneWidget);
      expect(find.text(Textos.sinCarpeta), findsOneWidget);
      expect(campoHabilitado(tester), isFalse);

      await tester.ensureVisible(find.text(Textos.seleccionarCarpeta));
      await tester.tap(find.text(Textos.seleccionarCarpeta));
      await tester.pump();
      expect(vecesSelector, 1);
      expect(find.text(Textos.primerUsoTitulo), findsOneWidget);
    });

    testWidgets('Raíz no encontrada: Reintentar y Elegir otra carpeta', (
      tester,
    ) async {
      final perdida = entorno.ruta('DESCONECTADO');
      var vecesSelector = 0;
      await montar(
        tester,
        raizGuardada: perdida,
        seleccionarCarpeta: () async {
          vecesSelector++;
          return null;
        },
      );

      expect(find.text(Textos.noEncontradaTitulo), findsOneWidget);
      expect(find.text(Textos.ultimaUbicacion(perdida)), findsOneWidget);
      expect(find.text(Textos.reintentar), findsOneWidget);
      expect(campoHabilitado(tester), isFalse);

      await tester.ensureVisible(find.text(Textos.elegirOtraCarpeta));
      await tester.tap(find.text(Textos.elegirOtraCarpeta));
      await tester.pump();
      expect(vecesSelector, 1);

      // Se "reconecta" el disco y se reintenta.
      entorno.raiz('DESCONECTADO');
      await tester.runAsync(raiz.reintentar);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(Textos.noEncontradaTitulo), findsNothing);
      expect(find.text(perdida), findsOneWidget);
      expect(campoHabilitado(tester), isTrue);
    });

    testWidgets('Carpeta METADA elegida: propone la carpeta padre', (
      tester,
    ) async {
      await montar(
        tester,
        sinConfiguracion: true,
        seleccionarCarpeta: () async => '$rutaRaiz\\METADA 2024',
      );
      await tester.runAsync(raiz.elegirCarpeta);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(Textos.propuestaTitulo), findsOneWidget);
      expect(
        find.text(Textos.propuestaDetalle('METADA 2024', rutaRaiz)),
        findsOneWidget,
      );
      expect(find.text(Textos.usarCarpetaPropuesta), findsOneWidget);
    });
  });
}
