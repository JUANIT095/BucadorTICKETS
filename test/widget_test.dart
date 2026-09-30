import 'package:buscador_tickets/app.dart';
import 'package:buscador_tickets/core/constants/textos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/entorno_prueba.dart';

final campoBusqueda = find.widgetWithText(TextField, Textos.pistaBusqueda);

void main() {
  testWidgets('La app arranca en estado inicial con el foco en la búsqueda', (
    tester,
  ) async {
    final entorno = EntornoPrueba.crear();
    addTearDown(entorno.eliminar);
    final raiz = (await tester.runAsync(
      () => crearRaizController(entorno, raizGuardada: entorno.raiz('DISCO')),
    ))!;
    addTearDown(raiz.dispose);

    await tester.pumpWidget(BuscadorTicketsApp(raiz: raiz));
    await tester.pump();

    expect(find.text(Textos.tituloPantalla), findsOneWidget);
    expect(find.text(Textos.pistaBusqueda), findsOneWidget);
    expect(find.text(Textos.estadoInicial), findsOneWidget);

    final campo = tester.widget<EditableText>(
      find.descendant(of: campoBusqueda, matching: find.byType(EditableText)),
    );
    expect(campo.focusNode.hasFocus, isTrue);
  });
}
