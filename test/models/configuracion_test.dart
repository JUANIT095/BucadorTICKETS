import 'package:buscador_tickets/models/configuracion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ida y vuelta JSON con ruta relativa', () {
    const config = Configuracion(
      raiz: r'E:\DISCO',
      raizRelativaExe: r'..\DISCO',
    );
    final leida = Configuracion.desdeJson(config.aJson())!;

    expect(leida.raiz, r'E:\DISCO');
    expect(leida.raizRelativaExe, r'..\DISCO');
  });

  test('sin ruta relativa no se escribe la clave', () {
    const config = Configuracion(raiz: r'\\servidor\datos');
    expect(config.aJson().containsKey('raizRelativaExe'), isFalse);
    expect(Configuracion.desdeJson(config.aJson())!.raizRelativaExe, isNull);
  });

  test('JSON nulo, de otra versión o incompleto ⇒ sin configuración', () {
    expect(Configuracion.desdeJson(null), isNull);
    expect(Configuracion.desdeJson({}), isNull);
    expect(Configuracion.desdeJson({'version': 99, 'raiz': r'E:\X'}), isNull);
    expect(Configuracion.desdeJson({'version': 1}), isNull);
    expect(Configuracion.desdeJson({'version': 1, 'raiz': '  '}), isNull);
    expect(Configuracion.desdeJson({'version': 1, 'raiz': 42}), isNull);
  });
}
