import 'dart:io';

import 'package:buscador_tickets/features/search/data/detector_meses.dart';
import 'package:buscador_tickets/features/search/data/parser_carpetas.dart';
import 'package:buscador_tickets/models/carpeta_anio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/entorno_prueba.dart';

void main() {
  late EntornoPrueba entorno;
  const detector = DetectorMeses();

  setUp(() => entorno = EntornoPrueba.crear());
  tearDown(() => entorno.eliminar());

  /// Crea `DISCO/<nombreAnio>/<carpeta>` para cada carpeta.
  CarpetaAnio anio(int valor, List<String> carpetas, {String? nombre}) {
    final nombreAnio = nombre ?? 'METADA $valor';
    final ruta = entorno.raiz(p.join('DISCO', nombreAnio), metada: carpetas);
    return CarpetaAnio(anio: valor, nombre: nombreAnio, ruta: ruta);
  }

  test('pareceTicket', () {
    expect(pareceTicket('100219_Curación2 ABC'), isTrue);
    expect(pareceTicket('100219 - Nombre'), isTrue);
    expect(pareceTicket('100219-Nombre'), isTrue);
    expect(pareceTicket('100219'), isTrue);
    expect(pareceTicket('05_Mayo'), isFalse);
    expect(pareceTicket('Varios'), isFalse);
    expect(pareceTicket('2024abc'), isFalse);
  });

  test('detecta los 12 meses con nombres variados', () async {
    final resultado = await detector.detectar([
      anio(2024, [
        'Enero',
        'FEBRERO',
        '03 Marzo',
        'Abr',
        'mayo',
        '06',
        'Julio 2024',
        'Agosto',
        'Setiembre',
        'Octubre',
        'Nov',
        'Diciembre',
      ]),
    ]);

    expect(
      [for (final c in resultado.carpetas) c.mes],
      [for (var m = 1; m <= 12; m++) m],
    );
    expect(resultado.noReconocidas, isEmpty);
    final marzo = resultado.carpetas[2];
    expect(marzo.nombre, '03 Marzo');
    expect(marzo.anio, 2024);
    expect(
      marzo.ruta,
      p.join(entorno.ruta('DISCO'), 'METADA 2024', '03 Marzo'),
    );
  });

  test(
    'varios años: orden año desc, mes asc, no reconocidas al final',
    () async {
      final resultado = await detector.detectar([
        anio(2024, ['Diciembre', 'Enero']),
        anio(2025, ['Pendientes', 'Mayo', 'Febrero']),
      ]);

      expect(
        [for (final c in resultado.carpetas) '${c.anio}/${c.nombre}'],
        [
          '2025/Febrero',
          '2025/Mayo',
          '2025/Pendientes',
          '2024/Enero',
          '2024/Diciembre',
        ],
      );
      expect(resultado.noReconocidas.single.mes, isNull);
    },
  );

  test(
    'carpeta con aspecto de ticket dentro del año ⇒ ticket sin mes',
    () async {
      final resultado = await detector.detectar([
        anio(2024, ['Mayo', '100219_Curación2 ABC - Proyecto IA', 'Varios']),
      ]);

      expect(
        resultado.ticketsSinMes.single.nombre,
        '100219_Curación2 ABC - Proyecto IA',
      );
      expect(resultado.ticketsSinMes.single.anio, 2024);
      expect(resultado.reconocidas.single.nombre, 'Mayo');
      expect(resultado.noReconocidas.single.nombre, 'Varios');
    },
  );

  test('duplicados del mismo mes: se conservan todos', () async {
    final resultado = await detector.detectar([
      anio(2024, ['Mayo', '05 Mayo', 'Junio']),
    ]);

    expect(resultado.reconocidas, hasLength(3));
    expect(resultado.duplicados, {
      (2024, 5): ['05 Mayo', 'Mayo'],
    });
  });

  test('ignora archivos; año vacío ⇒ sin carpetas y sin error', () async {
    final conArchivo = anio(2024, ['Mayo']);
    File(p.join(conArchivo.ruta, 'Junio')).writeAsStringSync('');
    final vacio = anio(2025, []);

    final resultado = await detector.detectar([conArchivo, vacio]);
    expect([for (final c in resultado.carpetas) c.nombre], ['Mayo']);
    expect(resultado.ilegibles, isEmpty);
  });

  test('una carpeta de año ilegible no impide leer las demás', () async {
    final buena = anio(2024, ['Mayo']);
    final perdida = CarpetaAnio(
      anio: 2025,
      nombre: 'METADA 2025',
      ruta: entorno.ruta(p.join('DISCO', 'METADA 2025')),
    );

    final resultado = await detector.detectar([buena, perdida]);
    expect(resultado.reconocidas.single.nombre, 'Mayo');
    expect(resultado.ilegibles.single.carpeta.nombre, 'METADA 2025');
  });

  test('dos carpetas del mismo año se recorren ambas', () async {
    final resultado = await detector.detectar([
      anio(2024, ['Mayo']),
      anio(2024, ['Junio'], nombre: 'metada_2024'),
    ]);
    expect([for (final c in resultado.carpetas) c.mes], [5, 6]);
  });
}
