import 'package:buscador_tickets/features/search/domain/filtros_busqueda.dart';
import 'package:buscador_tickets/features/search/domain/motor_busqueda.dart';
import 'package:buscador_tickets/models/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

Ticket _t(
  String carpeta, {
  int anio = 2024,
  int? mes = 5,
  String carpetaMes = 'Mayo',
}) {
  final separador = RegExp(r'^(\d+)_(.*)$').firstMatch(carpeta);
  return Ticket(
    numero: separador?.group(1),
    nombre: separador?.group(2) ?? carpeta,
    nombreCarpeta: carpeta,
    anio: anio,
    mes: mes,
    carpetaMes: carpetaMes,
    rutaRelativa: '$anio\\$carpetaMes\\$carpeta',
  );
}

/// Los tres tickets reales del disco.
final _reales = [
  _t('100219_Curación2 ABC - Proyecto IA'),
  _t('100222_Creación línea gráficaArtículo soporte HFC E&N'),
  _t('100226_Desarrollo contenidos virtuales Grandes Empresas - E&N'),
];

const _motor = MotorBusqueda();
const _sinFiltros = FiltrosBusqueda();

List<String> _buscar(
  List<Ticket> tickets,
  String consulta, [
  FiltrosBusqueda filtros = _sinFiltros,
]) => [
  for (final t in _motor.buscar(tickets, consulta, filtros).tickets)
    t.nombreCarpeta,
];

void main() {
  group('ejemplos del contexto (sección 7): todos encuentran 100219', () {
    for (final consulta in [
      '100219',
      'Curación2',
      'Proyecto IA',
      '100219_Curación2 ABC - Proyecto IA',
      'CURACION2',
      'curacion2',
      'Curacion2',
    ]) {
      test(consulta, () {
        expect(
          _buscar(_reales, consulta).first,
          '100219_Curación2 ABC - Proyecto IA',
        );
      });
    }
  });

  test('prioridad de la sección 8', () {
    final tickets = [
      _t('500000_Informe 100219'), // palabra clave / contiene en nombre
      _t('900100219_Otro'), // número contiene
      _t('1002190_Ampliación'), // número empieza
      _t('100219_Curación2'), // número exacto
      _t('300000_100219 resumen'), // nombre empieza
    ];
    expect(_buscar(tickets, '100219'), [
      '100219_Curación2',
      '1002190_Ampliación',
      '900100219_Otro',
      '300000_100219 resumen',
      '500000_Informe 100219',
    ]);
  });

  test('puntos por regla', () {
    final t = _reales.first;
    int p(String q) => MotorBusqueda.puntuar(
      t,
      q,
      q.split(' ').where((s) => s.isNotEmpty).toList(),
    );
    expect(p('100219'), Puntos.exacto);
    expect(p('100219_curacion2 abc - proyecto ia'), Puntos.exacto);
    expect(p('1002'), Puntos.numeroEmpieza);
    expect(p('0219'), Puntos.numeroContiene);
    expect(p('curacion'), Puntos.nombreEmpieza);
    expect(p('proyecto ia'), Puntos.nombreContiene);
    expect(p('ia curacion2'), Puntos.palabrasClave);
    expect(p('marketing'), 0);
  });

  test('palabras clave: deben aparecer TODAS', () {
    expect(_buscar(_reales, 'E&N grandes'), [
      '100226_Desarrollo contenidos virtuales Grandes Empresas - E&N',
    ]);
    expect(_buscar(_reales, 'E&N marketing'), isEmpty);
  });

  test('sin tildes ni mayúsculas en consulta ni en ticket', () {
    expect(_buscar(_reales, 'CREACION LINEA'), [
      '100222_Creación línea gráficaArtículo soporte HFC E&N',
    ]);
    expect(_buscar(_reales, 'gráfica'), [
      '100222_Creación línea gráficaArtículo soporte HFC E&N',
    ]);
  });

  test('número parcial devuelve todos los que lo contienen', () {
    expect(_buscar(_reales, '1002'), hasLength(3));
    expect(_buscar(_reales, '10022'), [
      '100222_Creación línea gráficaArtículo soporte HFC E&N',
      '100226_Desarrollo contenidos virtuales Grandes Empresas - E&N',
    ]);
  });

  test('desempate: año desc, mes desc, número asc', () {
    final tickets = [
      _t('200002_Prueba', anio: 2025, mes: 1, carpetaMes: 'Enero'),
      _t('100001_Prueba', anio: 2024, mes: 5),
      _t('200001_Prueba', anio: 2025, mes: 1, carpetaMes: 'Enero'),
      _t('300001_Prueba', anio: 2025, mes: 3, carpetaMes: 'Marzo'),
      _t('Prueba sin número', anio: 2025, mes: null, carpetaMes: ''),
    ];
    expect(_buscar(tickets, 'prueba'), [
      '300001_Prueba',
      '200001_Prueba',
      '200002_Prueba',
      'Prueba sin número',
      '100001_Prueba',
    ]);
  });

  test('números con distinta longitud y ceros: orden numérico', () {
    final tickets = [_t('1000_X'), _t('999_X'), _t('0998_X')];
    expect(_buscar(tickets, 'x'), ['0998_X', '999_X', '1000_X']);
  });

  test('filtros de año y mes se aplican antes de puntuar', () {
    final tickets = [
      _t('100219_Curación2', anio: 2024, mes: 5),
      _t('100219_Curación2 copia', anio: 2025, mes: 5),
      _t('100219_Curación2 junio', anio: 2024, mes: 6, carpetaMes: 'Junio'),
      _t('100219_Suelto', anio: 2024, mes: null, carpetaMes: ''),
    ];
    expect(
      _buscar(tickets, '100219', const FiltrosBusqueda(anio: 2024, mes: 5)),
      ['100219_Curación2'],
    );
    expect(_buscar(tickets, '100219', const FiltrosBusqueda(anio: 2025)), [
      '100219_Curación2 copia',
    ]);
    // Con un mes elegido, los tickets sin mes no aparecen.
    expect(_buscar(tickets, 'suelto', const FiltrosBusqueda(mes: 5)), isEmpty);
  });

  test('filtrar sin texto: todos los del año/mes, en orden de desempate', () {
    final tickets = [
      _t('100001_A', anio: 2024, mes: 5),
      _t('200002_B', anio: 2025, mes: 1, carpetaMes: 'Enero'),
      _t('200001_C', anio: 2025, mes: 1, carpetaMes: 'Enero'),
      _t('200003_D', anio: 2025, mes: 3, carpetaMes: 'Marzo'),
    ];
    final r = _motor.filtrar(tickets, const FiltrosBusqueda(anio: 2025));
    expect(
      [for (final t in r.tickets) t.nombreCarpeta],
      ['200003_D', '200001_C', '200002_B'],
    );
    expect(
      _motor.filtrar(tickets, const FiltrosBusqueda(anio: 2025, mes: 3)).total,
      1,
    );
  });

  test('límite de resultados con total real', () {
    final muchos = [for (var i = 0; i < 250; i++) _t('${100000 + i}_Lote')];
    final resultado = _motor.buscar(muchos, 'lote', _sinFiltros);
    expect(resultado.tickets, hasLength(200));
    expect(resultado.total, 250);
    expect(resultado.limitado, isTrue);
  });

  test('consulta vacía o solo espacios ⇒ sin resultados', () {
    expect(_motor.buscar(_reales, '   ', _sinFiltros).tickets, isEmpty);
  });

  test('sin coincidencias ⇒ lista vacía', () {
    expect(_buscar(_reales, 'zzz'), isEmpty);
  });
}
