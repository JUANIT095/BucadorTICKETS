import 'dart:io';

import 'package:buscador_tickets/core/services/acciones_sistema.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../helpers/entorno_prueba.dart';

void main() {
  late EntornoPrueba entorno;
  late List<String> lanzados;
  late AccionesSistema acciones;

  setUp(() {
    entorno = EntornoPrueba.crear();
    lanzados = [];
    // Explorador simulado: en las pruebas no se abre ninguna ventana.
    acciones = AccionesSistema(
      lanzar: (argumento) async => lanzados.add(argumento),
    );
  });
  tearDown(() => entorno.eliminar());

  test('carpeta existente ⇒ abre el Explorador en ella', () async {
    final raiz = entorno.raiz('DISCO', metada: ['2024']);
    final ticket = p.join(raiz, '2024', 'Mayo', '100219_Curación2 ABC - E&N');
    Directory(ticket).createSync(recursive: true);

    final resultado = await acciones.abrirCarpeta(ticket, raiz: raiz);
    expect(resultado, isA<CarpetaAbierta>());
    expect(lanzados, [AccionesSistema.argumentoExplorador(ticket)]);
  });

  test('ticket movido o borrado ⇒ no se abre nada y se explica', () async {
    final raiz = entorno.raiz('DISCO', metada: ['2024']);
    final resultado = await acciones.abrirCarpeta(
      p.join(raiz, '2024', 'Mayo', '100219_Borrado'),
      raiz: raiz,
    );
    expect(resultado, isA<TicketNoEncontrado>());
    expect(lanzados, isEmpty);
  });

  test('raíz no disponible (disco desconectado)', () async {
    final raiz = entorno.ruta('DESCONECTADO');
    final resultado = await acciones.abrirCarpeta(
      p.join(raiz, '2024', 'Mayo', '100219_X'),
      raiz: raiz,
    );
    expect(resultado, isA<UnidadNoDisponible>());
    expect(lanzados, isEmpty);
  });

  test('si el Explorador no arranca ⇒ error claro', () async {
    final raiz = entorno.raiz('DISCO', metada: ['2024']);
    final fallido = AccionesSistema(
      lanzar: (_) => throw const ProcessException('explorer.exe', []),
    );
    expect(
      await fallido.abrirCarpeta(p.join(raiz, '2024'), raiz: raiz),
      isA<ErrorAlAbrir>(),
    );
  });

  test('ruta de más de 259 caracteres ⇒ abre la carpeta más cercana', () async {
    final raiz = entorno.raiz('DISCO', metada: ['2024']);
    const tramo = 'Carpeta con nombre bastante largo para superar el limite';
    final ticket = p.join(raiz, '2024', tramo, tramo, tramo, tramo, '100300_T');
    Directory(ticket).createSync(recursive: true);
    expect(ticket.length, greaterThan(AccionesSistema.maximoRuta));

    final resultado = await acciones.abrirCarpeta(ticket, raiz: raiz);
    final cercana = (resultado as CarpetaCercanaAbierta).ruta;
    expect(cercana.length, lessThanOrEqualTo(AccionesSistema.maximoRuta));
    expect(p.isWithin(cercana, ticket), isTrue);
    expect(lanzados, [AccionesSistema.argumentoExplorador(cercana)]);
  });

  test('rutaAbrible no cambia rutas normales', () {
    const ruta = r'D:\2024\Mayo\100219_Curación2 ABC - Proyecto IA';
    expect(AccionesSistema.rutaAbrible(ruta), ruta);
  });

  test('copiar al portapapeles envía la ruta completa a Windows', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Object? enviado;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (llamada) async {
          if (llamada.method == 'Clipboard.setData') {
            enviado = llamada.arguments;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    const ruta = r'D:\2024\Mayo\100222_Creación línea gráfica E&N';
    expect(await copiarAlPortapapeles(ruta), isTrue);
    expect(enviado, {'text': ruta});
  });

  test('argumento con espacio final para forzar comillas (comas)', () {
    expect(
      AccionesSistema.argumentoExplorador(r'D:\2024\Mayo\100219_a,b'),
      r'D:\2024\Mayo\100219_a,b ',
    );
  });
}
