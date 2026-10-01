import 'dart:io';

import 'package:buscador_tickets/core/constants/app_constants.dart';
import 'package:buscador_tickets/core/constants/textos.dart';
import 'package:buscador_tickets/core/services/almacenamiento_portable.dart';
import 'package:buscador_tickets/features/search/data/escaner_directorios.dart';
import 'package:buscador_tickets/features/search/data/repositorio_indice.dart';
import 'package:buscador_tickets/features/search/domain/filtros_busqueda.dart';
import 'package:buscador_tickets/features/search/presentation/buscador_controller.dart';
import 'package:buscador_tickets/models/indice.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/entorno_prueba.dart';

void main() {
  late EntornoPrueba entorno;
  late String raiz;
  late AlmacenamientoPortable almacenamiento;
  late RepositorioIndice repositorio;
  final controladores = <BuscadorController>[];
  var escaneos = 0;

  setUp(() async {
    entorno = EntornoPrueba.crear();
    raiz = entorno.raiz('METADA', metada: ['2024', '2025']);
    Directory(
      p.join(raiz, '2024', 'Mayo', '100219_Curación2 ABC'),
    ).createSync(recursive: true);
    almacenamiento = await AlmacenamientoPortable.iniciar(
      rutaExe: entorno.exe(),
      localAppData: null,
    );
    repositorio = RepositorioIndice(almacenamiento);
    escaneos = 0;
  });

  tearDown(() {
    for (final c in controladores) {
      c.dispose();
    }
    controladores.clear();
    entorno.eliminar();
  });

  /// Controlador que cuenta los escaneos (para saber si usó el índice guardado).
  BuscadorController crear({RepositorioIndice? repo}) {
    final c = BuscadorController(
      repositorio: repo ?? repositorio,
      escaner: (r) {
        escaneos++;
        return escanearRaiz(r);
      },
    );
    controladores.add(c);
    return c;
  }

  test('sin índice guardado: indexa, guarda y carga los tickets', () async {
    final c = crear();
    await c.activarRaiz(raiz);

    expect(escaneos, 1);
    expect(c.tickets.single.numero, '100219');
    expect(c.anios, [2025, 2024]);
    expect(c.fechaIndice, isNotNull);
    expect(c.estado, isA<EstadoInicial>());
    expect(await repositorio.cargar(), isA<IndiceCargado>());
  });

  test('con índice guardado de la misma raíz: lo usa sin recorrer', () async {
    await crear().activarRaiz(raiz);
    // Un ticket nuevo en disco no aparece hasta actualizar el índice.
    Directory(
      p.join(raiz, '2025', 'Enero', '200001_Nuevo'),
    ).createSync(recursive: true);

    final segundo = crear();
    await segundo.activarRaiz(raiz);
    expect(escaneos, 1);
    expect(segundo.totalTickets, 1);

    await segundo.actualizarIndice(raiz);
    expect(escaneos, 2);
    expect(segundo.totalTickets, 2);
  });

  test('índice de otra raíz ⇒ se vuelve a indexar', () async {
    await crear().activarRaiz(raiz);
    final otra = entorno.raiz('OTRA', metada: ['2026']);

    final c = crear();
    await c.activarRaiz(otra);
    expect(escaneos, 2);
    expect(c.anios, [2026]);
    expect(c.tickets, isEmpty);
  });

  test('índice dañado ⇒ se regenera y se avisa', () async {
    await almacenamiento.escribirTexto(AppConstants.archivoIndice, '{roto');

    final c = crear();
    await c.activarRaiz(raiz);
    expect(escaneos, 1);
    expect(c.totalTickets, 1);
    expect(c.avisos, contains(Textos.avisoIndiceRegenerado));
  });

  test('sin conexión: busca en el último índice y avisa', () async {
    await crear().activarRaiz(raiz);

    final c = crear();
    await c.cargarSinConexion(raiz);
    expect(c.sinConexion, isTrue);
    expect(c.totalTickets, 1);
    expect(c.avisos, contains(Textos.avisoSinConexion(raiz)));
    expect(escaneos, 1);
  });

  test('sin conexión y sin índice de esa raíz ⇒ vacío', () async {
    final c = crear();
    await c.cargarSinConexion(raiz);
    expect(c.sinConexion, isFalse);
    expect(c.tickets, isEmpty);
  });

  test('desactivar vacía el índice en memoria y el filtro de año', () async {
    final c = crear();
    await c.activarRaiz(raiz);
    c.cambiarFiltros(const FiltrosBusqueda(anio: 2024));

    c.desactivar();
    expect(c.tickets, isEmpty);
    expect(c.anios, isEmpty);
    expect(c.fechaIndice, isNull);
    expect(c.filtros.anio, isNull);
  });

  test('fallo inesperado del recorrido ⇒ error claro', () async {
    final c = BuscadorController(escaner: (_) => Future.error(StateError('x')));
    controladores.add(c);
    await c.actualizarIndice(raiz);

    expect((c.estado as EstadoError).mensaje, Textos.errorIndexar);
    expect(c.indexando, isFalse);
  });

  test('avisos del índice guardado se muestran al cargarlo', () async {
    Directory(p.join(raiz, '2025', 'Pendientes')).createSync();
    await crear().activarRaiz(raiz);

    final c = crear();
    await c.activarRaiz(raiz);
    expect(escaneos, 1);
    expect(c.avisos, [
      Textos.avisoMesesNoReconocidos(['2025/Pendientes']),
    ]);
  });

  test('sin repositorio (memoria): siempre indexa', () async {
    final c = BuscadorController(
      escaner: (r) {
        escaneos++;
        return escanearRaiz(r);
      },
    );
    controladores.add(c);
    await c.activarRaiz(raiz);
    await c.activarRaiz(raiz);
    expect(escaneos, 2);
  });

  test('el índice guardado conserva años vacíos para el filtro', () async {
    await crear().activarRaiz(raiz);
    final carga = await repositorio.cargar() as IndiceCargado;
    final Indice indice = carga.indice;
    expect(indice.anios, [2025, 2024]);
  });
}
