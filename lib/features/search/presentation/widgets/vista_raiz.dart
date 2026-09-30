import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/textos.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/panel_vidrio.dart';
import '../raiz_controller.dart';

/// Panel central cuando no hay raíz activa: primer uso, no encontrada,
/// inválida o propuesta de carpeta padre.
class VistaRaiz extends StatelessWidget {
  const VistaRaiz({super.key, required this.controller});

  final RaizController controller;

  @override
  Widget build(BuildContext context) {
    final estado = controller.estado;
    final elegir = _Accion(Textos.elegirOtraCarpeta, controller.elegirCarpeta);

    final (icono, titulo, detalle, ruta, acciones) = switch (estado) {
      RaizSinConfigurar() => (
        Icons.drive_folder_upload_outlined,
        Textos.primerUsoTitulo,
        Textos.primerUsoDetalle,
        null,
        [_Accion(Textos.seleccionarCarpeta, controller.elegirCarpeta)],
      ),
      RaizNoEncontrada(:final ultimaRuta, :final coincidencias) => (
        Icons.usb_off_rounded,
        Textos.noEncontradaTitulo,
        coincidencias.length > 1
            ? Textos.noEncontradaVarias(coincidencias)
            : Textos.noEncontradaDetalle,
        Textos.ultimaUbicacion(ultimaRuta),
        [_Accion(Textos.reintentar, controller.reintentar), elegir],
      ),
      RaizInvalida(:final ruta, :final motivo) => (
        Icons.folder_off_outlined,
        Textos.invalidaTitulo,
        mensajeValidacion(motivo),
        ruta,
        [elegir],
      ),
      RaizPropuestaPadre(:final seleccionada, :final padre) => (
        Icons.subdirectory_arrow_left_rounded,
        Textos.propuestaTitulo,
        Textos.propuestaDetalle(p.basename(seleccionada), padre),
        null,
        [
          _Accion(Textos.usarCarpetaPropuesta, controller.usarPadre),
          elegir,
          _Accion(Textos.cancelar, controller.cancelarPropuesta),
        ],
      ),
      RaizVerificando() || RaizActiva() => (
        Icons.hourglass_empty_rounded,
        Textos.verificandoCarpeta,
        null,
        null,
        <_Accion>[],
      ),
    };

    final tema = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: PanelVidrio(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, size: 48, color: AppTheme.rojo),
                const SizedBox(height: 16),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleLarge,
                ),
                if (detalle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    detalle,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (ruta != null) ...[
                  const SizedBox(height: 12),
                  SelectableText(
                    ruta,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (final (i, accion) in acciones.indexed)
                      i == 0
                          ? FilledButton(
                              onPressed: accion.alPulsar,
                              child: Text(accion.texto),
                            )
                          : OutlinedButton(
                              onPressed: accion.alPulsar,
                              child: Text(accion.texto),
                            ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Accion {
  const _Accion(this.texto, this.alPulsar);

  final String texto;
  final VoidCallback alPulsar;
}
