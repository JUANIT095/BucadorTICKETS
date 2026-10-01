import 'dart:io';
import 'dart:isolate';

import 'package:buscador_tickets/core/constants/textos.dart';
import 'package:buscador_tickets/features/search/data/escaner_directorios.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/entorno_prueba.dart';

void main() {
  late EntornoPrueba entorno;
  late String raiz;

  setUp(() {
    entorno = EntornoPrueba.crear();
    raiz = entorno.raiz('METADA', metada: ['2024', '2025', '2026']);
  });
  tearDown(() => entorno.eliminar());

  void carpeta(String relativa) =>
      Directory(p.join(raiz, relativa)).createSync(recursive: true);

  test('recorrido completo dentro de un Isolate', () async {
    carpeta(p.join('2024', 'Mayo', '100219_Curación2 ABC - Proyecto IA'));
    carpeta(p.join('2024', 'Mayo', '100222_Creación línea gráfica E&N'));
    carpeta(p.join('2025', 'Enero', '200001_Prueba'));

    final indice = await Isolate.run(() => escanearRaiz(raiz));

    expect(indice.raiz, raiz);
    expect(indice.anios, [2026, 2025, 2024]);
    expect(
      [for (final t in indice.tickets) t.numero],
      ['200001', '100219', '100222'],
    );
    // Los campos normalizados viajan con el ticket desde el Isolate.
    expect(indice.tickets[1].nombreNorm, 'curacion2 abc - proyecto ia');
    expect(indice.avisos, isEmpty);
  });

  test('reúne los avisos de años, meses y tickets', () async {
    carpeta('2024 (copia)');
    carpeta(p.join('2025', 'Pendientes', 'Varios'));
    carpeta(p.join('2026', '300001_Suelto'));

    final indice = await escanearRaiz(raiz);
    expect(indice.avisos, [
      Textos.avisoCarpetasIgnoradas([
        Textos.carpetaIgnorada('2024 (copia)', false),
      ]),
      Textos.avisoMesesNoReconocidos(['2025/Pendientes']),
      Textos.avisoTicketsSinMes(1),
    ]);
    expect(
      [for (final t in indice.tickets) t.nombreCarpeta],
      ['300001_Suelto', 'Varios'],
    );
  });

  test('raíz inexistente ⇒ índice vacío con aviso, sin excepción', () async {
    final indice = await escanearRaiz(entorno.ruta('no_existe'));
    expect(indice.tickets, isEmpty);
    expect(indice.avisos, [
      Textos.avisoDeteccionFallida(Textos.motivoNoExiste),
    ]);
  });
}
