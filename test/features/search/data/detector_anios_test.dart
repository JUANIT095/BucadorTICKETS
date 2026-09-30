import 'dart:io';

import 'package:buscador_tickets/features/search/data/detector_anios.dart';
import 'package:buscador_tickets/features/search/data/parser_carpetas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/entorno_prueba.dart';

void main() {
  late EntornoPrueba entorno;
  const detector = DetectorAnios();

  setUp(() => entorno = EntornoPrueba.crear());
  tearDown(() => entorno.eliminar());

  Future<DeteccionAnios> detectar(List<String> carpetas) async {
    final raiz = entorno.raiz('DISCO', metada: carpetas);
    return await detector.detectar(raiz) as DeteccionAnios;
  }

  group('parser', () {
    test('extrae el año del nombre', () {
      expect(anioDeCarpeta('METADA 2024'), 2024);
      expect(anioDeCarpeta('  metada   2025 '), 2025);
      expect(anioDeCarpeta('Metada_2026'), 2026);
      expect(anioDeCarpeta('METADA-2027'), 2027);
      expect(anioDeCarpeta('METADA2028'), 2028);
      expect(anioDeCarpeta('METADATA 2024'), isNull);
      expect(anioDeCarpeta('METADA 2024 (copia)'), isNull);
      expect(anioDeCarpeta('Mayo'), isNull);
    });
  });

  test('detecta 2024, 2025 y 2026, y un año nuevo (2027)', () async {
    final resultado = await detectar([
      'METADA 2024',
      'METADA 2025',
      'METADA 2026',
      'METADA 2027',
    ]);

    expect(resultado.anios, [2027, 2026, 2025, 2024]);
    expect(resultado.ignoradas, isEmpty);
    final c2024 = resultado.carpetas.last;
    expect(c2024.nombre, 'METADA 2024');
    expect(c2024.ruta, p.join(entorno.ruta('DISCO'), 'METADA 2024'));
  });

  test('mayúsculas/minúsculas y espacios extra', () async {
    final resultado = await detectar(['metada  2024', 'Metada 2025 ']);
    expect(resultado.anios, [2025, 2024]);
  });

  test('orden: del año más reciente al más antiguo', () async {
    final resultado = await detectar([
      'METADA 2025',
      'METADA 2023',
      'METADA 2026',
      'METADA 2024',
    ]);
    expect(resultado.anios, [2026, 2025, 2024, 2023]);
  });

  test('ignora archivos con nombre METADA y carpetas sin patrón', () async {
    final raiz = entorno.raiz('DISCO', metada: ['METADA 2024', 'Otros']);
    File(p.join(raiz, 'METADA 2025')).writeAsStringSync('');
    File(p.join(raiz, 'notas.txt')).writeAsStringSync('');

    final resultado = await detector.detectar(raiz) as DeteccionAnios;
    expect(resultado.anios, [2024]);
    // "Otros" no se parece a METADA: no se registra como ignorada.
    expect(resultado.ignoradas, isEmpty);
  });

  test(
    'variantes: separadores aceptados; METADATA y "(copia)" ignoradas',
    () async {
      final resultado = await detectar([
        'METADA_2024',
        'METADA-2025',
        'METADATA 2026',
        'METADA 2024 (copia)',
      ]);

      expect(resultado.anios, [2025, 2024]);
      expect(
        [for (final c in resultado.ignoradas) (c.nombre, c.motivo)],
        [
          ('METADA 2024 (copia)', MotivoIgnorada.formatoNoReconocido),
          ('METADATA 2026', MotivoIgnorada.formatoNoReconocido),
        ],
      );
    },
  );

  test('duplicados: se conservan todas las carpetas del mismo año', () async {
    final resultado = await detectar([
      'METADA 2024',
      'metada_2024',
      'METADA 2025',
    ]);

    expect(resultado.anios, [2025, 2024]);
    expect(resultado.carpetas, hasLength(3));
    expect(resultado.duplicados, {
      2024: ['METADA 2024', 'metada_2024'],
    });
  });

  test('año fuera de rango se registra como ignorado', () async {
    final resultado = await detectar(['METADA 1999', 'METADA 2024']);

    expect(resultado.anios, [2024]);
    expect(resultado.ignoradas.single.motivo, MotivoIgnorada.anioFueraDeRango);
  });

  test('raíz sin carpetas METADA ⇒ lista vacía, sin error', () async {
    final resultado = await detectar(['Enero', 'Varios']);
    expect(resultado.carpetas, isEmpty);
    expect(resultado.anios, isEmpty);
  });

  test('raíz inexistente ⇒ fallo tipado, sin excepción', () async {
    final resultado = await detector.detectar(entorno.ruta('no_existe'));
    expect(
      (resultado as DeteccionFallida).motivo,
      MotivoFalloDeteccion.noExiste,
    );
  });
}
