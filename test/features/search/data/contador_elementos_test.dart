import 'dart:io';

import 'package:buscador_tickets/features/search/data/contador_elementos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/entorno_prueba.dart';

void main() {
  late EntornoPrueba entorno;

  setUp(() => entorno = EntornoPrueba.crear());
  tearDown(() => entorno.eliminar());

  test(
    'cuenta archivos y carpetas directas, sin entrar en subcarpetas',
    () async {
      final ticket = entorno.raiz('100219_Ticket', metada: ['recursos']);
      File(p.join(ticket, 'Brief.docx')).writeAsStringSync('');
      File(p.join(ticket, 'presentación.pptx')).writeAsStringSync('');
      File(p.join(ticket, 'recursos', 'archivo1')).writeAsStringSync('');

      expect(await contarElementos(ticket), 3);
    },
  );

  test('carpeta vacía ⇒ 0', () async {
    expect(await contarElementos(entorno.raiz('Vacio', metada: [])), 0);
  });

  test('carpeta que ya no existe ⇒ null (no disponible)', () async {
    expect(await contarElementos(entorno.ruta('borrado')), isNull);
  });
}
