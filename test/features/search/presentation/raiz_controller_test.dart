import 'package:buscador_tickets/core/constants/app_constants.dart';
import 'package:buscador_tickets/core/constants/textos.dart';
import 'package:buscador_tickets/core/services/almacenamiento_portable.dart';
import 'package:buscador_tickets/features/search/data/servicio_raiz.dart';
import 'package:buscador_tickets/features/search/presentation/raiz_controller.dart';
import 'package:buscador_tickets/models/configuracion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/entorno_prueba.dart';

void main() {
  late EntornoPrueba entorno;
  late AlmacenamientoPortable almacenamiento;
  late String exe;
  String? seleccion;
  var vecesSelector = 0;

  setUp(() async {
    entorno = EntornoPrueba.crear();
    exe = entorno.exe();
    almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: exe,
      localAppData: null,
    );
    seleccion = null;
    vecesSelector = 0;
  });
  tearDown(() => entorno.eliminar());

  RaizController crear({List<String> unidades = const []}) => RaizController(
    servicio: ServicioRaiz(rutaExe: exe, unidades: () async => unidades),
    almacenamiento: almacenamiento,
    seleccionarCarpeta: () async {
      vecesSelector++;
      return seleccion;
    },
  );

  Future<Configuracion?> configGuardada() async => Configuracion.desdeJson(
    await almacenamiento.leerJson(AppConstants.archivoConfig),
  );

  test('sin configuración ⇒ primer uso', () async {
    final raiz = crear();
    await raiz.iniciar();
    expect(raiz.estado, isA<RaizSinConfigurar>());
  });

  test(
    'elegir una raíz válida la activa y la guarda con ruta relativa',
    () async {
      final raiz = crear();
      await raiz.iniciar();
      seleccion = entorno.raiz('DISCO');
      await raiz.elegirCarpeta();

      expect(raiz.rutaActiva, seleccion);
      final config = (await configGuardada())!;
      expect(config.raiz, seleccion);
      expect(config.raizRelativaExe, r'..\DISCO');
    },
  );

  test('se recuerda entre ejecuciones', () async {
    final primera = crear();
    await primera.iniciar();
    seleccion = entorno.raiz('DISCO');
    await primera.elegirCarpeta();

    final segunda = crear();
    await segunda.iniciar();
    expect(segunda.rutaActiva, seleccion);
  });

  test('cancelar el selector no cambia nada', () async {
    final raiz = crear();
    await raiz.iniciar();
    await raiz.elegirCarpeta();

    expect(vecesSelector, 1);
    expect(raiz.estado, isA<RaizSinConfigurar>());
    expect(await configGuardada(), isNull);
  });

  test(
    'carpeta METADA ⇒ propone el padre y solo cambia al confirmar',
    () async {
      final raiz = crear();
      await raiz.iniciar();
      final disco = entorno.raiz('DISCO');
      seleccion = p.join(disco, 'METADA 2024');
      await raiz.elegirCarpeta();

      expect(raiz.estado, isA<RaizPropuestaPadre>());
      expect(await configGuardada(), isNull);

      await raiz.usarPadre();
      expect(raiz.rutaActiva, disco);
    },
  );

  test('cancelar la propuesta vuelve a la raíz anterior', () async {
    final raiz = crear();
    await raiz.iniciar();
    final disco = entorno.raiz('DISCO');
    seleccion = disco;
    await raiz.elegirCarpeta();

    seleccion = p.join(entorno.raiz('OTRO'), 'METADA 2024');
    await raiz.elegirCarpeta();
    raiz.cancelarPropuesta();

    expect(raiz.rutaActiva, disco);
  });

  test('carpeta inválida sin raíz previa ⇒ estado inválido', () async {
    final raiz = crear();
    await raiz.iniciar();
    seleccion = entorno.raiz('VACIA', metada: []);
    await raiz.elegirCarpeta();

    final estado = raiz.estado as RaizInvalida;
    expect(estado.motivo, isA<RaizSinMetada>());
  });

  test('carpeta inválida con raíz activa ⇒ la mantiene y avisa', () async {
    final raiz = crear();
    await raiz.iniciar();
    final disco = entorno.raiz('DISCO');
    seleccion = disco;
    await raiz.elegirCarpeta();

    seleccion = entorno.raiz('VACIA', metada: []);
    await raiz.elegirCarpeta();

    expect(raiz.rutaActiva, disco);
    expect(
      raiz.avisos,
      contains(Textos.avisoCarpetaNoValida(Textos.motivoSinMetada)),
    );
  });

  test('raíz guardada que ya no existe ⇒ no encontrada; reintentar', () async {
    final ruta = entorno.ruta('DISCO');
    await almacenamiento.escribirJson(
      AppConstants.archivoConfig,
      Configuracion(raiz: ruta).aJson(),
    );
    final raiz = crear();
    await raiz.iniciar();
    expect((raiz.estado as RaizNoEncontrada).ultimaRuta, ruta);

    entorno.raiz('DISCO');
    await raiz.reintentar();
    expect(raiz.rutaActiva, ruta);
  });

  test(
    'encontrada en otra letra ⇒ actualiza la configuración y avisa',
    () async {
      await almacenamiento.escribirJson(
        AppConstants.archivoConfig,
        const Configuracion(raiz: r'Q:\DISCO').aJson(),
      );
      final nueva = entorno.raiz(p.join('unidadF', 'DISCO'));
      final raiz = crear(unidades: [entorno.ruta('unidadF')]);
      await raiz.iniciar();

      expect(raiz.rutaActiva, nueva);
      expect((await configGuardada())!.raiz, nueva);
      expect(raiz.avisos, contains(Textos.avisoRaizDetectada(nueva)));
    },
  );
}
