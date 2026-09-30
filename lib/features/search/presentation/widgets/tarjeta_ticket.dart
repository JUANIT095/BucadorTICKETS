import 'package:flutter/material.dart';

import '../../../../core/constants/textos.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/ticket.dart';

/// Tarjeta de resultado con acciones Abrir carpeta y Copiar ruta.
///
/// Semitransparente sin desenfoque real (ver PanelVidrio); al pasar el mouse
/// el borde se vuelve rojo, brilla y se eleva un poco.
class TarjetaTicket extends StatefulWidget {
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
  State<TarjetaTicket> createState() => _TarjetaTicketState();
}

class _TarjetaTicketState extends State<TarjetaTicket> {
  var _encima = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ticket = widget.ticket;
    final elementos = widget.elementos;

    return MouseRegion(
      onEnter: (_) => setState(() => _encima = true),
      onExit: (_) => setState(() => _encima = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _encima ? -2 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _encima ? AppTheme.vidrioResaltado : AppTheme.vidrio,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _encima
                ? AppTheme.rojo.withValues(alpha: 0.8)
                : AppTheme.bordeVidrio,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.rojo.withValues(alpha: _encima ? 0.22 : 0),
              blurRadius: 24,
            ),
          ],
        ),
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
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.rojo, AppTheme.rojoProfundo],
                    ),
                  ),
                  child: const Icon(
                    Icons.folder_rounded,
                    color: AppTheme.blanco,
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
                                : Textos.elementos(elementos),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _Ubicacion(ruta: widget.ruta),
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
                FilledButton.icon(
                  onPressed: widget.onAbrir,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: const Text(Textos.abrirCarpeta),
                ),
                OutlinedButton.icon(
                  onPressed: widget.onCopiar,
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
