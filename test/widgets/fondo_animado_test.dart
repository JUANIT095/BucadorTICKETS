import 'package:buscador_tickets/widgets/fondo_animado.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Valor actual de la animación del fondo (0–1).
double _progreso(WidgetTester tester) {
  final pintor = tester
      .widget<CustomPaint>(
        find.descendant(
          of: find.byType(FondoAnimado),
          matching: find.byType(CustomPaint),
        ),
      )
      .painter;
  return ((pintor as dynamic).progreso as ValueNotifier<double>).value;
}

void main() {
  tearDown(
    () => TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    ),
  );

  testWidgets('se mueve, se pausa sin foco y se reanuda al volver', (
    tester,
  ) async {
    await tester.pumpWidget(const FondoAnimado(child: SizedBox.expand()));
    final inicio = _progreso(tester);
    await tester.pump(const Duration(seconds: 2));
    final enMovimiento = _progreso(tester);
    expect(enMovimiento, isNot(inicio));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(milliseconds: 200));
    final pausado = _progreso(tester);
    await tester.pump(const Duration(seconds: 3));
    expect(_progreso(tester), pausado);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 2));
    expect(_progreso(tester), isNot(pausado));
  });

  testWidgets('arranca animando aunque la ventana aún no esté activa', (
    tester,
  ) async {
    // Regresión: si se detenía antes del primer cuadro, en Windows la ventana
    // no llegaba a mostrarse y la app se cerraba sola.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpWidget(const FondoAnimado(child: SizedBox.expand()));
    final inicio = _progreso(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(_progreso(tester), isNot(inicio));
  });

  testWidgets('con animaciones desactivadas en Windows queda fijo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: FondoAnimado(child: SizedBox.expand()),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(_progreso(tester), 0.5);
  });
}
