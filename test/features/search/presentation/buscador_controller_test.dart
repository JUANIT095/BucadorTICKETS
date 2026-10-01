import 'package:buscador_tickets/core/constants/textos.dart';
import 'package:buscador_tickets/features/search/presentation/buscador_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/entorno_prueba.dart';

void main() {
  late EntornoPrueba entorno;
  late BuscadorController controller;

  setUp(() {
    entorno = EntornoPrueba.crear();
    controller = BuscadorController();
  });
  tearDown(() {
    controller.dispose();
    entorno.eliminar();
  });

  test('detecta años y meses, y avisa de lo no reconocido', () async {
    final raiz = entorno.raiz('DISCO', metada: ['METADA 2024', 'METADA 2025']);
    entorno.raiz(p.join('DISCO', 'METADA 2024'), metada: ['Mayo', 'Junio']);
    entorno.raiz(
      p.join('DISCO', 'METADA 2025'),
      metada: ['Enero', 'Pendientes', '100300_Suelto'],
    );

    await controller.detectarEstructura(raiz);

    expect(controller.anios, [2025, 2024]);
    expect(
      [
        for (final c in controller.carpetasMes)
          '${c.anio}/${c.nombre}/${c.mes}',
      ],
      ['2025/Enero/1', '2025/Pendientes/null', '2024/Mayo/5', '2024/Junio/6'],
    );
    expect(controller.ticketsSinMes.single.nombre, '100300_Suelto');
    // El ticket suelto en el año se incluye como ticket sin mes.
    expect(
      [for (final t in controller.tickets) t.nombreCarpeta],
      ['100300_Suelto'],
    );
    expect(controller.totalTickets, 1);
    expect(controller.avisos, [
      Textos.avisoMesesNoReconocidos(['2025/Pendientes']),
      Textos.avisoTicketsSinMes(1),
    ]);
    expect(controller.estado, isA<EstadoInicial>());
  });

  test('sin raíz activa se vacía la estructura', () async {
    final raiz = entorno.raiz('DISCO');
    entorno.raiz(p.join('DISCO', 'METADA 2024'), metada: ['Mayo']);
    await controller.detectarEstructura(raiz);
    expect(controller.carpetasMes, isNotEmpty);

    await controller.detectarEstructura(null);
    expect(controller.anios, isEmpty);
    expect(controller.carpetasMes, isEmpty);
    expect(controller.avisos, isEmpty);
  });
}
