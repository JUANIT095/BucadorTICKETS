import 'package:flutter/material.dart';

import '../../../../core/constants/textos.dart';
import '../../../../models/ticket.dart';

/// Tarjeta de resultado con acciones Abrir carpeta y Copiar ruta.
class TarjetaTicket extends StatelessWidget {
  const TarjetaTicket({
    super.key,
    required this.ticket,
    required this.ruta,
    required this.elementos,
    required this.onAbrir,
    required this.onCopiar,
  });

  final Ticket ticket;

  /// Ruta absoluta de la carpeta del ticket.
  final String ruta;

  /// Entradas directas de la carpeta; null mientras se calcula.
  final int? elementos;

  final VoidCallback onAbrir;
  final VoidCallback onCopiar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colores.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder_rounded,
                    color: colores.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.nombreCarpeta,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 24,
                        runSpacing: 4,
                        children: [
                          _Dato(
                            etiqueta: Textos.etiquetaTicket,
                            valor: ticket.numero ?? Textos.sinNumero,
                          ),
                          _Dato(
                            etiqueta: Textos.etiquetaAnio,
                            valor: '${ticket.anio}',
                          ),
                          _Dato(
                            etiqueta: Textos.etiquetaMes,
                            valor: ticket.carpetaMes,
                          ),
                          _Dato(
                            etiqueta: Textos.etiquetaElementos,
                            valor: elementos == null
                                ? Textos.calculando
                                : Textos.elementos(elementos!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _Ubicacion(ruta: ruta),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onAbrir,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: const Text(Textos.abrirCarpeta),
                ),
                OutlinedButton.icon(
                  onPressed: onCopiar,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text(Textos.copiarRuta),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$etiqueta: ',
            style: TextStyle(color: tema.colorScheme.onSurfaceVariant),
          ),
          TextSpan(
            text: valor,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      style: tema.textTheme.bodyMedium,
    );
  }
}

/// Ruta seleccionable en una sola línea, recortada con puntos suspensivos;
/// la ruta completa aparece en el tooltip.
class _Ubicacion extends StatelessWidget {
  const _Ubicacion({required this.ruta});

  final String ruta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      children: [
        Text(
          '${Textos.etiquetaUbicacion}: ',
          style: tema.textTheme.bodyMedium?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Tooltip(
            message: ruta,
            waitDuration: const Duration(milliseconds: 500),
            child: SelectionArea(
              child: Text(
                ruta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
