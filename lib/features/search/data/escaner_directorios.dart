import '../../../core/constants/textos.dart';
import '../../../models/indice.dart';
import 'detector_anios.dart';
import 'detector_meses.dart';
import 'detector_tickets.dart';

/// Recorrido completo de la raíz: años → meses → tickets. Solo lectura.
///
/// Es una función de nivel superior y sin dependencias de Flutter para poder
/// ejecutarse en un Isolate (`Isolate.run(() => escanearRaiz(raiz))`): con
/// muchos tickets, construirlos y normalizarlos no debe tocar el hilo de la UI.
Future<Indice> escanearRaiz(String raiz) async {
  final avisos = <String>[];
  var erroresLectura = 0;

  final anios = await const DetectorAnios().detectar(raiz);
  final carpetasAnio = switch (anios) {
    DeteccionAnios() => anios.carpetas,
    DeteccionFallida() => const <Never>[],
  };
  switch (anios) {
    case DeteccionAnios():
      erroresLectura += anios.erroresLectura;
      avisos.addAll(_avisosDeAnios(anios));
    case DeteccionFallida(:final motivo):
      avisos.add(
        Textos.avisoDeteccionFallida(switch (motivo) {
          MotivoFalloDeteccion.noExiste => Textos.motivoNoExiste,
          MotivoFalloDeteccion.sinPermisos => Textos.motivoSinPermisos,
          MotivoFalloDeteccion.noResponde => Textos.motivoNoResponde,
        }),
      );
  }

  final meses = await const DetectorMeses().detectar(carpetasAnio);
  erroresLectura += meses.erroresLectura;
  avisos.addAll(_avisosDeMeses(meses));

  final tickets = await const DetectorTickets().detectar(raiz, meses);
  erroresLectura += tickets.erroresLectura;
  if (tickets.ilegibles.isNotEmpty) {
    avisos.add(
      Textos.avisoMesesIlegibles([
        for (final i in tickets.ilegibles)
          '${i.carpeta.anio}/${i.carpeta.nombre}',
      ]),
    );
  }
  if (erroresLectura > 0) {
    avisos.add(Textos.avisoErroresLectura(erroresLectura));
  }

  return Indice(
    raiz: raiz,
    generado: DateTime.now(),
    anios: {for (final c in carpetasAnio) c.anio}.toList(),
    tickets: tickets.tickets,
    avisos: avisos,
  );
}

List<String> _avisosDeAnios(DeteccionAnios anios) => [
  if (anios.carpetas.isEmpty) Textos.sinAnios,
  for (final MapEntry(key: anio, value: nombres) in anios.duplicados.entries)
    Textos.avisoAnioDuplicado(anio, nombres),
  if (anios.ignoradas.isNotEmpty)
    Textos.avisoCarpetasIgnoradas([
      for (final c in anios.ignoradas)
        Textos.carpetaIgnorada(
          c.nombre,
          c.motivo == MotivoIgnorada.anioFueraDeRango,
        ),
    ]),
];

List<String> _avisosDeMeses(DeteccionMeses meses) => [
  for (final MapEntry(key: (anio, mes), value: nombres)
      in meses.duplicados.entries)
    Textos.avisoMesDuplicado(anio, mes, nombres),
  if (meses.noReconocidas.isNotEmpty)
    Textos.avisoMesesNoReconocidos([
      for (final c in meses.noReconocidas) '${c.anio}/${c.nombre}',
    ]),
  if (meses.ticketsSinMes.isNotEmpty)
    Textos.avisoTicketsSinMes(meses.ticketsSinMes.length),
  if (meses.ilegibles.isNotEmpty)
    Textos.avisoAniosIlegibles([
      for (final i in meses.ilegibles) i.carpeta.nombre,
    ]),
];
