import 'package:buscador_tickets/core/utils/normalizador.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mayúsculas y tildes: Curación = curacion = CURACION', () {
    expect(normalizar('Curación'), 'curacion');
    expect(normalizar('CURACIÓN'), 'curacion');
    expect(normalizar('curacion'), 'curacion');
  });

  test('vocales con tilde, diéresis y ñ', () {
    expect(normalizar('ÁÉÍÓÚ áéíóú Üü Ññ'), 'aeiou aeiou uu nn');
    expect(
      normalizar('Creación línea gráficaArtículo'),
      'creacion linea graficaarticulo',
    );
  });

  test('diacríticos combinantes (forma NFD, p. ej. copiado desde Mac)', () {
    // "o" + U+0301 (tilde aparte) y "n" + U+0303.
    expect(normalizar('Curacio\u0301n Espan\u0303a'), 'curacion espana');
  });

  test('espacios: colapsa repetidos y recorta extremos', () {
    expect(normalizar('  Proyecto    IA  '), 'proyecto ia');
  });

  test('conserva números y otros signos', () {
    expect(
      normalizar('100219_Curación2 ABC - E&N'),
      '100219_curacion2 abc - e&n',
    );
  });

  test('palabras: separa por espacio, _, - y –', () {
    expect(palabrasNormalizadas('100219_Curación2 ABC - Proyecto IA'), [
      '100219',
      'curacion2',
      'abc',
      'proyecto',
      'ia',
    ]);
    expect(palabrasNormalizadas('a–b__c'), ['a', 'b', 'c']);
    expect(palabrasNormalizadas('   '), isEmpty);
  });
}
