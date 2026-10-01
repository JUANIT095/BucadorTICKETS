import 'dart:io';

import 'package:buscador_tickets/features/search/data/servicio_raiz.dart';
import 'package:buscador_tickets/models/configuracion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/entorno_prueba.dart';

/// Unidad inexistente en el equipo, para simular la letra guardada.
const _rutaEnOtraUnidad = r'Q:\DISCO';

void main() {
  late EntornoPrueba entorno;

  setUp(() => entorno = EntornoPrueba.crear());
  tearDown(() => entorno.eliminar());

  ServicioRaiz servicio({
    String? exe,
    List<String> unidades = const [],
    void Function()? alConsultarUnidades,
  }) => ServicioRaiz(
    rutaExe: exe ?? entorno.exe(),
    unidades: () async {
      alConsultarUnidades?.call();
      return unidades;
    },
    limiteValidacion: const Duration(seconds: 2),
    limitePorUnidad: const Duration(seconds: 2),
  );

  group('validar', () {
    test('raíz con carpeta METADA ⇒ válida', () async {
      final raiz = entorno.raiz('DISCO');
      expect(await servicio().validar(raiz), isA<RaizValida>());
    });

    test('tildes, espacios y mayúsculas/minúsculas en METADA', () async {
      final raiz = entorno.raiz(
        'Curación2 ABC - Proyecto IA',
        metada: ['metada  2025'],
      );
      expect(await servicio().validar(raiz), isA<RaizValida>());
      expect(
        await servicio().validar(entorno.raiz('B', metada: ['Metada 2026'])),
        isA<RaizValida>(),
      );
      expect(
        await servicio().validar(entorno.raiz('C', metada: ['METADA_2024'])),
        isA<RaizValida>(),
      );
    });

    test('formato real del disco: carpetas "2024", "2025", "2026"', () async {
      final raiz = entorno.raiz('METADA', metada: ['2024', '2025', '2026']);
      expect(await servicio().validar(raiz), isA<RaizValida>());
    });

    test('elegir la carpeta "2024" propone la carpeta padre', () async {
      final raiz = entorno.raiz('METADA', metada: ['2024']);
      final resultado = await servicio().validar(p.join(raiz, '2024'));

      expect((resultado as RaizEsCarpetaAnio).padre, raiz);
    });

    test('carpeta inexistente ⇒ no existe', () async {
      expect(
        await servicio().validar(entorno.ruta('no_existe')),
        isA<RaizNoExiste>(),
      );
    });

    test('sin carpetas METADA (un archivo con ese nombre no cuenta)', () async {
      final raiz = entorno.raiz('DISCO', metada: ['Otra carpeta']);
      File(p.join(raiz, 'METADA 2024')).writeAsStringSync('');
      expect(await servicio().validar(raiz), isA<RaizSinAnios>());
    });

    test('elegir una carpeta METADA propone la carpeta padre', () async {
      final raiz = entorno.raiz('DISCO');
      final resultado = await servicio().validar(p.join(raiz, 'METADA 2024'));

      expect(resultado, isA<RaizEsCarpetaAnio>());
      expect((resultado as RaizEsCarpetaAnio).padre, raiz);
    });
  });

  group('resolver', () {
    test('sin configuración', () async {
      expect(
        await servicio().resolver(null),
        isA<ResolucionSinConfiguracion>(),
      );
    });

    test('ruta absoluta guardada', () async {
      final raiz = entorno.raiz('DISCO');
      final resultado = await servicio().resolver(Configuracion(raiz: raiz));

      expect(resultado, isA<ResolucionEncontrada>());
      resultado as ResolucionEncontrada;
      expect(resultado.ruta, raiz);
      expect(resultado.cambioDeUbicacion, isFalse);
    });

    test('ruta relativa al .exe tiene prioridad (disco USB)', () async {
      final exe = entorno.exe(p.join('USB', 'App'));
      final raiz = entorno.raiz(p.join('USB', 'DISCO'));
      final resultado = await servicio(exe: exe).resolver(
        const Configuracion(
          raiz: _rutaEnOtraUnidad,
          raizRelativaExe: r'..\DISCO',
        ),
      );

      resultado as ResolucionEncontrada;
      expect(resultado.ruta, raiz);
      expect(resultado.cambioDeUbicacion, isTrue);
    });

    test('cambio de letra: la ruta aparece en otra unidad', () async {
      final unidadE = entorno.ruta('unidadE');
      final unidadF = entorno.ruta('unidadF');
      Directory(unidadE).createSync();
      final raiz = entorno.raizConMes(p.join('unidadF', 'DISCO'));

      final resultado = await servicio(
        unidades: [unidadE, unidadF],
      ).resolver(const Configuracion(raiz: _rutaEnOtraUnidad));

      resultado as ResolucionEncontrada;
      expect(resultado.ruta, raiz);
      expect(resultado.cambioDeUbicacion, isTrue);
    });

    test('otra unidad con carpeta "2024" pero sin meses no se toma', () async {
      // P. ej. un USB de fotos con una carpeta "2024": no es la raíz.
      entorno.raiz(p.join('unidadFotos', 'DISCO'), metada: ['2024']);

      final resultado = await servicio(
        unidades: [entorno.ruta('unidadFotos')],
      ).resolver(const Configuracion(raiz: _rutaEnOtraUnidad));

      expect(resultado, isA<ResolucionNoEncontrada>());
    });

    test(
      'varias unidades válidas ⇒ no elige y devuelve las opciones',
      () async {
        entorno.raizConMes(p.join('unidadE', 'DISCO'));
        entorno.raizConMes(p.join('unidadF', 'DISCO'));

        final resultado = await servicio(
          unidades: [entorno.ruta('unidadE'), entorno.ruta('unidadF')],
        ).resolver(const Configuracion(raiz: _rutaEnOtraUnidad));

        resultado as ResolucionNoEncontrada;
        expect(resultado.ultimaRuta, _rutaEnOtraUnidad);
        expect(resultado.coincidencias, hasLength(2));
      },
    );

    test('ninguna encontrada', () async {
      final resultado = await servicio(
        unidades: [entorno.ruta('vacia')],
      ).resolver(const Configuracion(raiz: _rutaEnOtraUnidad));

      resultado as ResolucionNoEncontrada;
      expect(resultado.coincidencias, isEmpty);
    });

    test('ruta UNC: solo absoluta, sin probar otras unidades', () async {
      var unidadesConsultadas = false;
      final resultado = await servicio(
        unidades: [entorno.ruta('x')],
        alConsultarUnidades: () => unidadesConsultadas = true,
      ).resolver(const Configuracion(raiz: r'\\servidor-inexistente\c\DISCO'));

      expect(resultado, isA<ResolucionNoEncontrada>());
      expect(unidadesConsultadas, isFalse);
    });
  });

  group('configuracionPara', () {
    test('misma unidad que el .exe ⇒ guarda también la relativa', () {
      final exe = entorno.exe(p.join('USB', 'App'));
      final raiz = entorno.raiz(p.join('USB', 'DISCO'));
      final config = servicio(exe: exe).configuracionPara(raiz);

      expect(config.raiz, raiz);
      expect(config.raizRelativaExe, r'..\DISCO');
    });

    test('otra unidad o ruta UNC ⇒ solo absoluta', () {
      expect(
        servicio().configuracionPara(_rutaEnOtraUnidad).raizRelativaExe,
        isNull,
      );
      expect(
        servicio().configuracionPara(r'\\servidor\datos').raizRelativaExe,
        isNull,
      );
    });
  });
}
