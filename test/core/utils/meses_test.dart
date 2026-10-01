import 'package:buscador_tickets/core/utils/meses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nombres completos, sin distinguir mayúsculas', () {
    const esperados = {
      'Enero': 1,
      'FEBRERO': 2,
      'marzo': 3,
      'Abril': 4,
      'Mayo': 5,
      'Junio': 6,
      'Julio': 7,
      'Agosto': 8,
      'Septiembre': 9,
      'Octubre': 10,
      'Noviembre': 11,
      'Diciembre': 12,
    };
    esperados.forEach((nombre, mes) => expect(mesDeCarpeta(nombre), mes));
  });

  test('Setiembre, abreviaturas y prefijos', () {
    expect(mesDeCarpeta('Setiembre'), 9);
    expect(mesDeCarpeta('Sep'), 9);
    expect(mesDeCarpeta('Set'), 9);
    expect(mesDeCarpeta('Sept'), 9);
    expect(mesDeCarpeta('Ene'), 1);
    expect(mesDeCarpeta('Dic'), 12);
    expect(mesDeCarpeta('Novi'), 11);
  });

  test('nombre con número o año', () {
    expect(mesDeCarpeta('05 Mayo'), 5);
    expect(mesDeCarpeta('05-Mayo'), 5);
    expect(mesDeCarpeta('05_mayo'), 5);
    expect(mesDeCarpeta('Mayo 2024'), 5);
    expect(mesDeCarpeta('  mayo  '), 5);
    // Si el número no coincide, manda el nombre.
    expect(mesDeCarpeta('06 Mayo'), 5);
  });

  test('solo número', () {
    expect(mesDeCarpeta('05'), 5);
    expect(mesDeCarpeta('5'), 5);
    expect(mesDeCarpeta('12'), 12);
    expect(mesDeCarpeta('05-2024'), 5);
    expect(mesDeCarpeta('2024_05'), 5);
  });

  test('no reconocidos', () {
    expect(mesDeCarpeta('13'), isNull);
    expect(mesDeCarpeta('00'), isNull);
    expect(mesDeCarpeta('Semana 1'), isNull);
    expect(mesDeCarpeta('Pendientes'), isNull);
    expect(mesDeCarpeta('Mayorista'), isNull);
    expect(mesDeCarpeta('Enero-Febrero'), isNull);
    expect(mesDeCarpeta('100219_Curación2 ABC'), isNull);
    expect(mesDeCarpeta('Ma'), isNull);
  });
}
