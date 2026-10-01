import 'package:buscador_tickets/models/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

Ticket _ejemplo({
  String ruta = r'2024\Mayo\100219_Curación2 ABC - Proyecto IA',
}) => Ticket(
  numero: '100219',
  nombre: 'Curación2 ABC - Proyecto IA',
  nombreCarpeta: '100219_Curación2 ABC - Proyecto IA',
  anio: 2024,
  mes: 5,
  carpetaMes: 'Mayo',
  rutaRelativa: ruta,
);

void main() {
  test('campos normalizados para buscar', () {
    final ticket = _ejemplo();
    expect(ticket.numeroNorm, '100219');
    expect(ticket.nombreNorm, 'curacion2 abc - proyecto ia');
    expect(ticket.carpetaNorm, '100219_curacion2 abc - proyecto ia');
    expect(ticket.palabras, ['100219', 'curacion2', 'abc', 'proyecto', 'ia']);
  });

  test('sin número ⇒ número normalizado vacío', () {
    final ticket = Ticket(
      nombre: 'Varios',
      nombreCarpeta: 'Varios',
      anio: 2025,
      carpetaMes: 'Pendientes',
      rutaRelativa: r'2025\Pendientes\Varios',
    );
    expect(ticket.numeroNorm, '');
  });

  test('ruta absoluta para la raíz actual', () {
    expect(
      _ejemplo().rutaEn(r'D:\'),
      r'D:\2024\Mayo\100219_Curación2 ABC - Proyecto IA',
    );
    expect(
      _ejemplo().rutaEn(r'F:\'),
      r'F:\2024\Mayo\100219_Curación2 ABC - Proyecto IA',
    );
  });

  test('JSON de ida y vuelta (formato del índice)', () {
    final json = _ejemplo().aJson();
    expect(json, {
      'numero': '100219',
      'nombre': 'Curación2 ABC - Proyecto IA',
      'anio': 2024,
      'mes': 5,
      'carpetaMes': 'Mayo',
      'ruta': r'2024\Mayo\100219_Curación2 ABC - Proyecto IA',
    });

    final leido = Ticket.desdeJson(json)!;
    expect(leido.nombreCarpeta, '100219_Curación2 ABC - Proyecto IA');
    expect(leido.numero, '100219');
    expect(leido.mes, 5);
    expect(leido.palabras, _ejemplo().palabras);
  });

  test('sin número y sin mes: las claves se omiten y se leen como null', () {
    final ticket = Ticket(
      nombre: 'Suelto',
      nombreCarpeta: 'Suelto',
      anio: 2026,
      carpetaMes: '',
      rutaRelativa: r'2026\Suelto',
    );
    final json = ticket.aJson();
    expect(json.containsKey('numero'), isFalse);
    expect(json.containsKey('mes'), isFalse);

    final leido = Ticket.desdeJson(json)!;
    expect(leido.numero, isNull);
    expect(leido.mes, isNull);
    expect(leido.carpetaMes, '');
  });

  test('entrada dañada ⇒ null (se descarta sin romper la carga)', () {
    final valido = _ejemplo().aJson();
    expect(Ticket.desdeJson(null), isNull);
    expect(Ticket.desdeJson('texto'), isNull);
    expect(Ticket.desdeJson({...valido}..remove('ruta')), isNull);
    expect(Ticket.desdeJson({...valido, 'ruta': '  '}), isNull);
    expect(Ticket.desdeJson({...valido, 'anio': '2024'}), isNull);
    expect(Ticket.desdeJson({...valido, 'mes': 13}), isNull);
    expect(Ticket.desdeJson({...valido, 'numero': 100219}), isNull);
  });

  test('igualdad por ruta, sin distinguir mayúsculas', () {
    expect(_ejemplo(), _ejemplo());
    expect(
      _ejemplo(),
      _ejemplo(ruta: r'2024\MAYO\100219_curación2 abc - proyecto ia'),
    );
    // Mismo número en otro mes ⇒ otro ticket.
    expect(_ejemplo(), isNot(_ejemplo(ruta: r'2024\Junio\100219_Otro')));
    expect({_ejemplo(), _ejemplo()}, hasLength(1));
  });
}
