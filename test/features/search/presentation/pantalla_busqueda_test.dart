import 'dart:io';

import 'package:buscador_tickets/core/constants/textos.dart';
import 'package:buscador_tickets/core/theme/app_theme.dart';
import 'package:buscador_tickets/features/search/domain/filtros_busqueda.dart';
import 'package:buscador_tickets/features/search/presentation/buscador_controller.dart';
import 'package:buscador_tickets/features/search/presentation/pantalla_busqueda.dart';
import 'package:buscador_tickets/features/search/presentation/raiz_controller.dart';
import 'package:buscador_tickets/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/entorno_prueba.dart';
import '../../../helpers/tickets_prueba.dart';

final campoBusqueda = find.widgetWithText(TextField, Textos.pistaBusqueda);

void main() {
  late EntornoPrueba entorno;
  late BuscadorController controller;
  late RaizController raiz;
  late String rutaRaiz;

  /// Rutas cuyo conteo de elementos se pidió.
  final conteos = <String>[];

  setUp(() {
    entorno = EntornoPrueba.crear();
    rutaRaiz = entorno.raiz('DISCO');
    conteos.clear();
    controller = BuscadorController(
      fechaIndice: TicketsPrueba.fechaIndice,
      tickets: TicketsPrueba.tickets,
      // Conteo simulado: sin E/S real en las pruebas de widget.
      contador: (ruta) async {
        conteos.add(ruta);
        return ruta.contains("Varios") ? null : 12;
      },
    );
  });

  tearDown(() {
    controller.dispose();
    raiz.dispose();
    entorno.eliminar();
  });

  /// Monta la pantalla con el área útil de la ventana en su tamaño mínimo
  /// (800x600 menos bordes y barra de título); un desborde hace fallar la prueba.
  /// Por defecto hay una raíz válida guardada.
  Future<void> montar(
    WidgetTester tester, {
    String? raizGuardada,
    bool sinConfiguracion = false,
    Future<String?> Function()? seleccionarCarpeta,
  }) async {
    tester.view.physicalSize = const Size(784, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    raiz = (await tester.runAsync(
      () => crearRaizController(
        entorno,
        raizGuardada: sinConfiguracion ? null : raizGuardada ?? rutaRaiz,
        seleccionarCarpeta: seleccionarCarpeta,
      ),
    ))!;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.oscuro,
        home: PantallaBusqueda(controller: controller, raiz: raiz),
      ),
    );
  }

  bool campoHabilitado(WidgetTester tester) =>
      tester.widget<TextField>(campoBusqueda).enabled ?? true;

  Future<void> mostrar(WidgetTester tester, EstadoBusqueda estado) async {
    controller.mostrarEstado(estado);
    await tester.pump();
  }

  testWidgets('Estado inicial', (tester) async {
    await montar(tester);
    expect(find.text(Textos.estadoInicial), findsOneWidget);
  });

  testWidgets('Estado buscando', (tester) async {
    await montar(tester);
    await mostrar(tester, const EstadoBuscando());
    expect(find.text(Textos.estadoBuscando), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Estado indexando', (tester) async {
    await montar(tester);
    await mostrar(tester, const EstadoIndexando());
    expect(find.text(Textos.estadoIndexando), findsOneWidget);
  });

  testWidgets('Estado sin resultados', (tester) async {
    await montar(tester);
    await mostrar(tester, const EstadoSinResultados());
    expect(find.text(Textos.sinResultados), findsOneWidget);
    expect(find.text(Textos.sinResultadosDetalle), findsOneWidget);
  });

  testWidgets('Estado de error muestra el mensaje', (tester) async {
    await montar(tester);
    await mostrar(tester, const EstadoError(Textos.errorIndexar));
    expect(find.text(Textos.estadoError), findsOneWidget);
    expect(find.text(Textos.errorIndexar), findsOneWidget);
  });

  testWidgets('Resultados recortados: "Mostrando 2 de 250"', (tester) async {
    await montar(tester);
    await mostrar(
      tester,
      EstadoConResultados(TicketsPrueba.tickets.take(2).toList(), total: 250),
    );
    expect(find.text(Textos.resultadosLimitados(2, 250)), findsOneWidget);
  });

  testWidgets('Estado con resultados muestra tarjetas y acciones', (
    tester,
  ) async {
    await montar(tester);
    await mostrar(tester, EstadoConResultados(TicketsPrueba.tickets));
    expect(find.text(Textos.resultados(5)), findsOneWidget);
    expect(find.text('100219_Curación2 ABC - Proyecto IA'), findsOneWidget);
    expect(find.text(Textos.abrirCarpeta), findsWidgets);
    expect(find.text(Textos.copiarRuta), findsWidgets);
  });

  group('Elementos', () {
    Finder dato(String valor) => find.textContaining(valor, findRichText: true);

    testWidgets('muestra el conteo real cuando termina', (tester) async {
      await montar(tester);
      await mostrar(tester, EstadoConResultados(TicketsPrueba.tickets));
      await tester.pump(); // resuelve el conteo simulado

      expect(dato(Textos.elementos(12)), findsWidgets);
      expect(
        conteos.first,
        '$rutaRaiz\\2024\\Mayo\\100219_Curación2 ABC - Proyecto IA',
      );
    });

    testWidgets('solo se cuentan las tarjetas construidas (visibles)', (
      tester,
    ) async {
      final muchos = [
        for (var i = 0; i < 40; i++)
          Ticket(
            numero: '${100000 + i}',
            nombre: 'Lote',
            nombreCarpeta: '${100000 + i}_Lote',
            anio: 2024,
            mes: 5,
            carpetaMes: 'Mayo',
            rutaRelativa: '2024\\Mayo\\${100000 + i}_Lote',
          ),
      ];
      await montar(tester);
      await mostrar(tester, EstadoConResultados(muchos));
      await tester.pump();

      expect(conteos, isNotEmpty);
      expect(conteos.length, lessThan(muchos.length));
    });

    testWidgets('carpeta no disponible ⇒ "No disponible"', (tester) async {
      await montar(tester);
      final varios = TicketsPrueba.tickets.firstWhere(
        (t) => t.nombre == 'Varios',
      );
      await mostrar(tester, EstadoConResultados([varios]));
      await tester.pump();

      expect(dato(Textos.elementosNoDisponible), findsOneWidget);
    });

    testWidgets('cada carpeta se cuenta una sola vez por sesión', (
      tester,
    ) async {
      await montar(tester);
      final uno = [TicketsPrueba.tickets.first];
      await mostrar(tester, EstadoConResultados(uno));
      await tester.pump();
      await mostrar(tester, const EstadoInicial());
      await mostrar(tester, EstadoConResultados(uno));
      await tester.pump();

      expect(conteos, hasLength(1));
    });
  });

  testWidgets('Enter busca y mantiene el foco en el campo', (tester) async {
    await montar(tester);
    await tester.enterText(campoBusqueda, 'curacion');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(find.text('100219_Curación2 ABC - Proyecto IA'), findsOneWidget);
    final campo = tester.widget<EditableText>(
      find.descendant(of: campoBusqueda, matching: find.byType(EditableText)),
    );
    expect(campo.focusNode.hasFocus, isTrue);
  });

  testWidgets('El aviso se muestra y se puede cerrar', (tester) async {
    await montar(tester);
    controller.mostrarAviso(Textos.avisoIndiceRegenerado);
    await tester.pump();
    expect(find.text(Textos.avisoIndiceRegenerado), findsOneWidget);

    await tester.tap(find.byTooltip(Textos.cerrarAviso));
    await tester.pump();
    expect(find.text(Textos.avisoIndiceRegenerado), findsNothing);
  });

  testWidgets('Encabezado y pie muestran raíz, fecha y total', (tester) async {
    await montar(tester);
    expect(find.text(rutaRaiz), findsOneWidget);
    expect(find.text(Textos.cambiarCarpeta), findsOneWidget);
    expect(find.text(Textos.actualizarIndice), findsOneWidget);
    expect(
      find.text(Textos.indiceActualizado(TicketsPrueba.fechaIndice)),
      findsOneWidget,
    );
    expect(find.text(Textos.ticketsIndexados(5)), findsOneWidget);
  });

  group('Filtro Año', () {
    // El fondo animado es infinito: se usan esperas fijas, no pumpAndSettle.
    Future<void> abrirFiltroAnio(WidgetTester tester) async {
      await tester.tap(find.byType(DropdownMenu<int>).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    /// Texto que muestra el campo del filtro Año.
    String textoFiltroAnio(WidgetTester tester) => tester
        .widget<EditableText>(
          find.descendant(
            of: find.byType(DropdownMenu<int>).first,
            matching: find.byType(EditableText),
          ),
        )
        .controller
        .text;

    testWidgets('muestra "Todos" y los años detectados', (tester) async {
      entorno.raiz('DISCO', metada: ['METADA 2025', 'METADA 2027']);
      await montar(tester);
      await tester.runAsync(() => controller.actualizarIndice(rutaRaiz));
      await tester.pump();

      expect(controller.anios, [2027, 2025, 2024]);
      await abrirFiltroAnio(tester);
      // El menú también construye una copia oculta de las opciones para
      // medir su ancho, por eso cada opción puede aparecer más de una vez.
      for (final opcion in [Textos.todos, '2027', '2025', '2024']) {
        expect(find.widgetWithText(MenuItemButton, opcion), findsWidgets);
      }
      expect(find.widgetWithText(MenuItemButton, '2026'), findsNothing);
    });

    testWidgets('vuelve a "Todos" si el año elegido desaparece', (
      tester,
    ) async {
      entorno.raiz('DISCO', metada: ['METADA 2025']);
      await montar(tester);
      await tester.runAsync(() => controller.actualizarIndice(rutaRaiz));
      controller.cambiarFiltros(const FiltrosBusqueda(anio: 2025));
      await tester.pump();
      expect(textoFiltroAnio(tester), '2025');

      Directory('$rutaRaiz\\METADA 2025').deleteSync();
      await tester.runAsync(() => controller.actualizarIndice(rutaRaiz));
      await tester.pump();

      expect(controller.filtros.anio, isNull);
      expect(controller.anios, [2024]);
      expect(textoFiltroAnio(tester), Textos.todos);
    });

    testWidgets('raíz sin años válidos ⇒ aviso claro', (tester) async {
      await montar(tester);
      Directory('$rutaRaiz\\METADA 2024').renameSync('$rutaRaiz\\METADA 1999');
      await tester.runAsync(() => controller.actualizarIndice(rutaRaiz));
      await tester.pump();

      expect(find.text(Textos.sinAnios), findsOneWidget);
    });
  });

  group('Índice', () {
    /// Espera (en tiempo real) a que termine la indexación.
    Future<void> esperarIndexacion(WidgetTester tester) async {
      for (var i = 0; i < 100 && controller.indexando; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('"Actualizar índice" vuelve a recorrer la raíz', (
      tester,
    ) async {
      Directory(
        '$rutaRaiz\\METADA 2024\\Mayo\\100219_Curación2 ABC',
      ).createSync(recursive: true);
      await montar(tester);
      expect(controller.totalTickets, 5); // aún los de demostración

      final boton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, Textos.actualizarIndice),
      );
      await tester.runAsync(() async => boton.onPressed!());
      await esperarIndexacion(tester);

      expect(controller.totalTickets, 1);
      expect(find.text(Textos.ticketsIndexados(1)), findsOneWidget);
    });

    testWidgets('sin conexión: busca en el último índice y avisa', (
      tester,
    ) async {
      // Índice guardado de una raíz que luego "se desconecta".
      final disco = entorno.raiz('USB', metada: ['2024']);
      Directory(
        '$disco\\2024\\Mayo\\100219_Curación2 ABC',
      ).createSync(recursive: true);
      final repositorio = (await tester.runAsync(
        () => crearRepositorio(entorno, 'datos_indice'),
      ))!;
      controller.dispose();
      controller = BuscadorController(
        repositorio: repositorio,
        contador: (_) async => null,
      );
      await tester.runAsync(() => controller.activarRaiz(disco));
      Directory(disco).deleteSync(recursive: true);

      await montar(tester, raizGuardada: disco);
      await tester.runAsync(() => controller.cargarSinConexion(disco));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(controller.sinConexion, isTrue);
      expect(find.text(Textos.avisoSinConexion(disco)), findsOneWidget);
      expect(find.text(Textos.noEncontradaTitulo), findsNothing);
      expect(campoHabilitado(tester), isTrue);

      await tester.enterText(campoBusqueda, '100219');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(find.text('100219_Curación2 ABC'), findsOneWidget);
    });
  });

  group('Carpeta raíz', () {
    testWidgets('Primer uso: pide la carpeta y deshabilita la búsqueda', (
      tester,
    ) async {
      var vecesSelector = 0;
      await montar(
        tester,
        sinConfiguracion: true,
        seleccionarCarpeta: () async {
          vecesSelector++;
          return null;
        },
      );

      expect(find.text(Textos.primerUsoTitulo), findsOneWidget);
      expect(find.text(Textos.sinCarpeta), findsOneWidget);
      expect(campoHabilitado(tester), isFalse);

      await tester.ensureVisible(find.text(Textos.seleccionarCarpeta));
      await tester.tap(find.text(Textos.seleccionarCarpeta));
      await tester.pump();
      expect(vecesSelector, 1);
      expect(find.text(Textos.primerUsoTitulo), findsOneWidget);
    });

    testWidgets('Raíz no encontrada: Reintentar y Elegir otra carpeta', (
      tester,
    ) async {
      final perdida = entorno.ruta('DESCONECTADO');
      var vecesSelector = 0;
      await montar(
        tester,
        raizGuardada: perdida,
        seleccionarCarpeta: () async {
          vecesSelector++;
          return null;
        },
      );

      expect(find.text(Textos.noEncontradaTitulo), findsOneWidget);
      expect(find.text(Textos.ultimaUbicacion(perdida)), findsOneWidget);
      expect(find.text(Textos.reintentar), findsOneWidget);
      expect(campoHabilitado(tester), isFalse);

      await tester.ensureVisible(find.text(Textos.elegirOtraCarpeta));
      await tester.tap(find.text(Textos.elegirOtraCarpeta));
      await tester.pump();
      expect(vecesSelector, 1);

      // Se "reconecta" el disco y se reintenta.
      entorno.raiz('DESCONECTADO');
      await tester.runAsync(raiz.reintentar);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(Textos.noEncontradaTitulo), findsNothing);
      expect(find.text(perdida), findsOneWidget);
      expect(campoHabilitado(tester), isTrue);
    });

    testWidgets('Carpeta METADA elegida: propone la carpeta padre', (
      tester,
    ) async {
      await montar(
        tester,
        sinConfiguracion: true,
        seleccionarCarpeta: () async => '$rutaRaiz\\METADA 2024',
      );
      await tester.runAsync(raiz.elegirCarpeta);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(Textos.propuestaTitulo), findsOneWidget);
      expect(
        find.text(Textos.propuestaDetalle('METADA 2024', rutaRaiz)),
        findsOneWidget,
      );
      expect(find.text(Textos.usarCarpetaPropuesta), findsOneWidget);
    });
  });
}
