import 'dart:io';

import 'package:buscador_tickets/features/search/data/detector_anios.dart';
import 'package:buscador_tickets/features/search/data/detector_meses.dart';
import 'package:buscador_tickets/features/search/data/detector_tickets.dart';
import 'package:buscador_tickets/features/search/data/parser_carpetas.dart';
import 'package:buscador_tickets/models/ticket.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/entorno_prueba.dart';

void main() {
  late EntornoPrueba entorno;
  late String raiz;

  setUp(() {
    entorno = EntornoPrueba.crear();
    raiz = entorno.raiz('METADA', metada: ['2024', '2025', '2026']);
  });
  tearDown(() => entorno.eliminar());

  /// Crea carpetas de ticket en `<raiz>\<anio>\<mes>`.
  void tickets(String anio, String mes, List<String> nombres) {
    for (final n in nombres) {
      Directory(p.join(raiz, anio, mes, n)).createSync(recursive: true);
    }
  }

  /// Recorrido completo: años → meses → tickets.
  Future<DeteccionTickets> detectar() async {
    final anios = await const DetectorAnios().detectar(raiz) as DeteccionAnios;
    final meses = await const DetectorMeses().detectar(anios.carpetas);
    return const DetectorTickets().detectar(raiz, meses);
  }

  group('numeroYNombreDeTicket', () {
    test('formato habitual y nombres reales del disco', () {
      expect(numeroYNombreDeTicket('100219_Curación2 ABC - Proyecto IA'), (
        numero: '100219',
        nombre: 'Curación2 ABC - Proyecto IA',
      ));
      expect(
        numeroYNombreDeTicket(
          '100222_Creación línea gráficaArtículo soporte HFC E&N',
        ),
        (
          numero: '100222',
          nombre: 'Creación línea gráficaArtículo soporte HFC E&N',
        ),
      );
    });

    test('otros separadores y solo el primer corte', () {
      for (final nombre in [
        '101045 - Rediseño',
        '101045-Rediseño',
        '101045 Rediseño',
        '101045 – Rediseño',
        '101045__Rediseño',
      ]) {
        expect(numeroYNombreDeTicket(nombre), (
          numero: '101045',
          nombre: 'Rediseño',
        ), reason: nombre);
      }
      expect(numeroYNombreDeTicket('100219_ABC_v2'), (
        numero: '100219',
        nombre: 'ABC_v2',
      ));
    });

    test('solo número, sin número y ceros a la izquierda', () {
      expect(numeroYNombreDeTicket('100219'), (numero: '100219', nombre: ''));
      expect(numeroYNombreDeTicket('Varios'), (numero: null, nombre: 'Varios'));
      expect(numeroYNombreDeTicket('123abc'), (numero: null, nombre: '123abc'));
      expect(numeroYNombreDeTicket('000123_Prueba'), (
        numero: '000123',
        nombre: 'Prueba',
      ));
    });
  });

  test('estructura real: 3 tickets en 2024/Mayo, 2025 y 2026 vacíos', () async {
    tickets('2024', 'Mayo', [
      '100219_Curación2 ABC - Proyecto IA',
      '100222_Creación línea gráficaArtículo soporte HFC E&N',
      '100226_Desarrollo contenidos virtuales Grandes Empresas - E&N',
    ]);

    final resultado = await detectar();
    expect(resultado.tickets, hasLength(3));
    final primero = resultado.tickets.first;
    expect(primero.numero, '100219');
    expect(primero.nombre, 'Curación2 ABC - Proyecto IA');
    expect(primero.anio, 2024);
    expect(primero.mes, 5);
    expect(primero.carpetaMes, 'Mayo');
    expect(
      primero.rutaRelativa,
      p.join('2024', 'Mayo', '100219_Curación2 ABC - Proyecto IA'),
    );
    expect(resultado.ilegibles, isEmpty);
  });

  test(
    'orden: año desc, mes asc, sin mes al final; números duplicados',
    () async {
      tickets('2025', 'Febrero', ['200001_B']);
      tickets('2025', 'Enero', ['200002_A', '200001_Repetido']);
      tickets('2024', 'Diciembre', ['100001_Z']);
      tickets('2025', 'Pendientes', ['Varios']);

      final resultado = await detectar();
      String clave(Ticket t) => '${t.anio}/${t.carpetaMes}/${t.nombreCarpeta}';
      expect(
        [for (final t in resultado.tickets) clave(t)],
        [
          '2025/Enero/200001_Repetido',
          '2025/Enero/200002_A',
          '2025/Febrero/200001_B',
          '2025/Pendientes/Varios',
          '2024/Diciembre/100001_Z',
        ],
      );
      final varios = resultado.tickets[3];
      expect(varios.mes, isNull);
      expect(varios.numero, isNull);
    },
  );

  test('ticket guardado directamente en el año ⇒ ticket sin mes', () async {
    Directory(p.join(raiz, '2026', '300001_Suelto')).createSync();

    final resultado = await detectar();
    final suelto = resultado.tickets.single;
    expect(suelto.numero, '300001');
    expect(suelto.mes, isNull);
    expect(suelto.carpetaMes, '');
    expect(suelto.rutaRelativa, p.join('2026', '300001_Suelto'));
  });

  test('ignora archivos y no entra en el contenido del ticket', () async {
    tickets('2024', 'Mayo', ['100219_Ticket']);
    File(p.join(raiz, '2024', 'Mayo', 'notas.txt')).writeAsStringSync('');
    Directory(
      p.join(raiz, '2024', 'Mayo', '100219_Ticket', 'recursos'),
    ).createSync();

    final resultado = await detectar();
    expect(
      [for (final t in resultado.tickets) t.nombreCarpeta],
      ['100219_Ticket'],
    );
  });

  test('un mes ilegible no impide leer los demás', () async {
    tickets('2024', 'Mayo', ['100219_Ticket']);
    final anios = await const DetectorAnios().detectar(raiz) as DeteccionAnios;
    final meses = await const DetectorMeses().detectar(anios.carpetas);
    // El mes desaparece entre la detección de meses y la de tickets.
    Directory(p.join(raiz, '2024', 'Junio')).createSync();
    final conJunio = await const DetectorMeses().detectar(anios.carpetas);
    Directory(p.join(raiz, '2024', 'Junio')).deleteSync();

    final resultado = await const DetectorTickets().detectar(raiz, conJunio);
    expect(resultado.tickets.single.nombreCarpeta, '100219_Ticket');
    expect(resultado.ilegibles.single.carpeta.nombre, 'Junio');
    expect(meses.carpetas, hasLength(1));
  });
}
