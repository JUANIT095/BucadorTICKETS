import 'package:buscador_tickets/app.dart';
import 'package:buscador_tickets/core/constants/textos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('La app arranca y muestra el título', (tester) async {
    await tester.pumpWidget(const BuscadorTicketsApp());

    expect(find.text(Textos.tituloApp), findsOneWidget);
  });
}
