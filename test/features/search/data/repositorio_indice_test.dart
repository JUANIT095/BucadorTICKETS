import 'package:buscador_tickets/core/constants/app_constants.dart';
import 'package:buscador_tickets/core/services/almacenamiento_portable.dart';
import 'package:buscador_tickets/features/search/data/repositorio_indice.dart';
import 'package:buscador_tickets/models/indice.dart';
import 'package:buscador_tickets/models/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/entorno_prueba.dart';

Indice _indice() => Indice(
  raiz: r'D:\',
  generado: DateTime(2026, 10, 1, 9, 30),
  anios: [2026, 2025, 2024],
  avisos: ['Un aviso'],
  tickets: [
    Ticket(
      numero: '100219',
      nombre: 'Curación2 ABC - Proyecto IA',
      nombreCarpeta: '100219_Curación2 ABC - Proyecto IA',
      anio: 2024,
      mes: 5,
      carpetaMes: 'Mayo',
      rutaRelativa: r'2024\Mayo\100219_Curación2 ABC - Proyecto IA',
    ),
  ],
);

void main() {
  late EntornoPrueba entorno;
  late AlmacenamientoPortable almacenamiento;
  late RepositorioIndice repositorio;

  setUp(() async {
    entorno = EntornoPrueba.crear();
    almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: entorno.exe(),
      localAppData: null,
    );
    repositorio = RepositorioIndice(almacenamiento);
  });
  tearDown(() => entorno.eliminar());

  test('sin archivo ⇒ sin índice', () async {
    expect(await repositorio.cargar(), isA<SinIndice>());
  });

  test('guardar y cargar (UTF-8, ida y vuelta)', () async {
    expect(await repositorio.guardar(_indice()), isTrue);

    final cargado = (await repositorio.cargar() as IndiceCargado).indice;
    expect(cargado.raiz, r'D:\');
    expect(cargado.generado, DateTime(2026, 10, 1, 9, 30));
    expect(cargado.anios, [2026, 2025, 2024]);
    expect(cargado.avisos, ['Un aviso']);
    final ticket = cargado.tickets.single;
    expect(ticket.nombre, 'Curación2 ABC - Proyecto IA');
    expect(ticket.nombreNorm, 'curacion2 abc - proyecto ia');
  });

  test('JSON corrupto u otra versión ⇒ dañado', () async {
    await almacenamiento.escribirTexto(AppConstants.archivoIndice, '{roto');
    expect(await repositorio.cargar(), isA<IndiceDanado>());

    await almacenamiento.escribirJson(AppConstants.archivoIndice, {
      ..._indice().aJson(),
      'version': 99,
    });
    expect(await repositorio.cargar(), isA<IndiceDanado>());
  });

  test('un ticket dañado se descarta sin perder el resto', () async {
    final json = _indice().aJson();
    (json['tickets'] as List).add({'nombre': 'sin ruta'});
    await almacenamiento.escribirJson(AppConstants.archivoIndice, json);

    final cargado = (await repositorio.cargar() as IndiceCargado).indice;
    expect(cargado.tickets, hasLength(1));
  });
}
