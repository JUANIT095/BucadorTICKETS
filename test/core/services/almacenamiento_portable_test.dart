import 'dart:io';

import 'package:buscador_tickets/core/services/almacenamiento_portable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../helpers/entorno_prueba.dart';

void main() {
  late EntornoPrueba entorno;

  setUp(() => entorno = EntornoPrueba.crear());
  tearDown(() => entorno.eliminar());

  test('usa data_usuario junto al .exe cuando se puede escribir', () async {
    final exe = entorno.exe();
    final almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: exe,
      localAppData: entorno.ruta('local'),
    );

    expect(almacenamiento.ubicacion, UbicacionDatos.principal);
    expect(almacenamiento.carpeta, p.join(p.dirname(exe), 'data_usuario'));
    expect(Directory(almacenamiento.carpeta!).existsSync(), isTrue);
  });

  test('guarda y lee JSON, y sobrescribe de forma atómica', () async {
    final almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: entorno.exe(),
      localAppData: null,
    );

    expect(await almacenamiento.escribirJson('x.json', {'a': 1}), isTrue);
    expect(
      await almacenamiento.escribirJson('x.json', {'a': 'Curación'}),
      isTrue,
    );
    expect(await almacenamiento.leerJson('x.json'), {'a': 'Curación'});
    expect(
      File(p.join(almacenamiento.carpeta!, 'x.json.tmp')).existsSync(),
      isFalse,
    );
  });

  test('archivo inexistente, corrupto o que no es objeto ⇒ null', () async {
    final almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: entorno.exe(),
      localAppData: null,
    );
    final carpeta = almacenamiento.carpeta!;
    File(p.join(carpeta, 'corrupto.json')).writeAsStringSync('{ no es json');
    File(p.join(carpeta, 'lista.json')).writeAsStringSync('[1, 2]');
    File(p.join(carpeta, 'vacio.json')).writeAsStringSync('');

    expect(await almacenamiento.leerJson('no_existe.json'), isNull);
    expect(await almacenamiento.leerJson('corrupto.json'), isNull);
    expect(await almacenamiento.leerJson('lista.json'), isNull);
    expect(await almacenamiento.leerJson('vacio.json'), isNull);
  });

  test('si junto al .exe no se puede escribir, usa el respaldo', () async {
    // La "carpeta" del .exe es en realidad un archivo: no se puede crear
    // data_usuario dentro.
    File(entorno.ruta('bloqueo')).writeAsStringSync('');
    final almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: p.join(entorno.ruta('bloqueo'), 'BuscadorTickets.exe'),
      localAppData: entorno.ruta('local'),
    );

    expect(almacenamiento.ubicacion, UbicacionDatos.respaldo);
    expect(
      almacenamiento.carpeta,
      p.join(entorno.ruta('local'), 'BuscadorTickets'),
    );
  });

  test('nunca crea data_usuario dentro de una carpeta METADA', () async {
    final exe = entorno.exe(p.join('DISCO', 'METADA 2024', 'App'));
    final almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: exe,
      localAppData: entorno.ruta('local'),
    );

    expect(almacenamiento.ubicacion, UbicacionDatos.respaldo);
    expect(
      Directory(p.join(p.dirname(exe), 'data_usuario')).existsSync(),
      isFalse,
    );
  });

  test('tampoco dentro de una carpeta de año "2024"', () async {
    final exe = entorno.exe(p.join('METADA', '2024', 'App'));
    final almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: exe,
      localAppData: entorno.ruta('local'),
    );
    expect(almacenamiento.ubicacion, UbicacionDatos.respaldo);
  });

  test('app junto a las carpetas de año (raíz = unidad) ⇒ principal', () async {
    // Caso real: D:\BuscadorTickets\ junto a D:\2024, D:\2025…
    entorno.raiz('METADA', metada: ['2024', '2025']);
    final exe = entorno.exe(p.join('METADA', 'BuscadorTickets'));
    final almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: exe,
      localAppData: entorno.ruta('local'),
    );
    expect(almacenamiento.ubicacion, UbicacionDatos.principal);
  });

  test('lectura de un "archivo" que en realidad es carpeta ⇒ null', () async {
    final almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: entorno.exe(),
      localAppData: null,
    );
    Directory(p.join(almacenamiento.carpeta!, 'raro.json')).createSync();
    expect(await almacenamiento.leerTexto('raro.json'), isNull);
  });

  test('si la carpeta de datos desaparece, guardar devuelve false', () async {
    final almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: entorno.exe(),
      localAppData: null,
    );
    final carpeta = almacenamiento.carpeta!;
    Directory(carpeta).deleteSync(recursive: true);
    File(carpeta).writeAsStringSync(''); // un archivo ocupa su lugar
    expect(await almacenamiento.escribirTexto('x.json', '{}'), isFalse);
  });

  test('sin ubicación escribible trabaja en memoria', () async {
    File(entorno.ruta('bloqueo')).writeAsStringSync('');
    final almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: p.join(entorno.ruta('bloqueo'), 'BuscadorTickets.exe'),
      localAppData: null,
    );

    expect(almacenamiento.ubicacion, UbicacionDatos.memoria);
    expect(await almacenamiento.escribirJson('x.json', {'a': 1}), isTrue);
    expect(await almacenamiento.leerJson('x.json'), {'a': 1});
  });
}
