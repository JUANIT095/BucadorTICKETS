import 'package:buscador_tickets/core/constants/textos.dart';
import 'package:buscador_tickets/core/theme/app_theme.dart';
import 'package:buscador_tickets/features/search/presentation/buscador_controller.dart';
import 'package:buscador_tickets/features/search/presentation/datos_demo.dart';
import 'package:buscador_tickets/features/search/presentation/pantalla_busqueda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final campoBusqueda = find.widgetWithText(TextField, Textos.pistaBusqueda);

void main() {
  late BuscadorController controller;

  setUp(() {
    controller = BuscadorController(
      raiz: DatosDemo.raiz,
      fechaIndice: DatosDemo.fechaIndice,
      tickets: DatosDemo.tickets,
    );
  });

  tearDown(() => controller.dispose());

  /// Monta la pantalla con el área útil de la ventana en su tamaño mínimo
  /// (800x600 menos bordes y barra de título); un desborde hace fallar la prueba.
  Future<void> montar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(784, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.oscuro,
        home: PantallaBusqueda(controller: controller),
      ),
    );
  }

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
    expect(find.text(DatosDemo.raiz), findsOneWidget);
    expect(find.text(Textos.cambiarCarpeta), findsOneWidget);
    expect(find.text(Textos.actualizarIndice), findsOneWidget);
    expect(
      find.text(Textos.indiceActualizado(DatosDemo.fechaIndice)),
      findsOneWidget,
    );
    expect(find.text(Textos.ticketsIndexados(5)), findsOneWidget);
  });
}
