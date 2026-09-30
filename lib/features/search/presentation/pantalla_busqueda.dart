import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/textos.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ticket.dart';
import '../../../widgets/banner_aviso.dart';
import 'buscador_controller.dart';
import 'datos_demo.dart';
import 'widgets/barra_busqueda.dart';
import 'widgets/panel_filtros.dart';
import 'widgets/tarjeta_ticket.dart';
import 'widgets/vista_estado.dart';

/// Pantalla principal de búsqueda.
class PantallaBusqueda extends StatelessWidget {
  const PantallaBusqueda({super.key, required this.controller});

  final BuscadorController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Scaffold(
        // TEMPORAL (Fase 12): selector de estados de demostración.
        floatingActionButton: kDebugMode
            ? SelectorEstadoDemo(controller: controller)
            : null,
        body: Column(
          children: [
            _Encabezado(raiz: controller.raiz),
            _Centrado(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  BarraBusqueda(
                    onBuscar: controller.buscar,
                    filtros: PanelFiltros(
                      anios: controller.anios,
                      filtros: controller.filtros,
                      onCambio: controller.cambiarFiltros,
                    ),
                  ),
                  for (final aviso in controller.avisos) ...[
                    const SizedBox(height: 12),
                    BannerAviso(
                      mensaje: aviso,
                      onCerrar: () => controller.descartarAviso(aviso),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: switch (controller.estado) {
                EstadoInicial() => const VistaEstado.inicial(),
                EstadoBuscando() => const VistaEstado.buscando(),
                EstadoIndexando() => const VistaEstado.indexando(),
                EstadoSinResultados() => const VistaEstado.sinResultados(),
                EstadoError(:final mensaje) => VistaEstado.error(
                  mensaje: mensaje,
                ),
                EstadoConResultados(:final tickets) => _ListaResultados(
                  tickets: tickets,
                  raiz: controller.raiz,
                ),
              },
            ),
            _Pie(
              fechaIndice: controller.fechaIndice,
              totalTickets: controller.totalTickets,
            ),
          ],
        ),
      ),
    );
  }
}

/// Limita el ancho al máximo del contenido y lo centra.
class _Centrado extends StatelessWidget {
  const _Centrado({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppTheme.anchoMaximoContenido,
        ),
        child: Padding(
          padding: padding.add(const EdgeInsets.symmetric(horizontal: 24)),
          child: child,
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.raiz});

  final String? raiz;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final textoRaiz = raiz ?? Textos.sinCarpeta;

    return Material(
      color: colores.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.manage_search_rounded, color: colores.primary),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    Textos.tituloPantalla,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.titleMedium?.copyWith(
                      color: colores.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 18,
                        color: colores.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Tooltip(
                          message: textoRaiz,
                          child: Text(
                            textoRaiz,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.bodyMedium?.copyWith(
                              color: colores.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Sin lógica todavía: Fase 5 (carpeta) y Fase 10 (índice).
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.drive_folder_upload_outlined),
                  label: const Text(Textos.cambiarCarpeta),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(Textos.actualizarIndice),
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class _ListaResultados extends StatelessWidget {
  const _ListaResultados({required this.tickets, required this.raiz});

  final List<Ticket> tickets;
  final String? raiz;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    // La lista ocupa todo el ancho (barra de desplazamiento en el borde de la
    // ventana) y el margen centra las tarjetas en el ancho máximo.
    return LayoutBuilder(
      builder: (context, restricciones) {
        final margen =
            math.max(
              0.0,
              (restricciones.maxWidth - AppTheme.anchoMaximoContenido) / 2,
            ) +
            24;

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(margen, 0, margen, 24),
          itemCount: tickets.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Text(
                Textos.resultados(tickets.length),
                style: tema.textTheme.labelLarge?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              );
            }
            final ticket = tickets[i - 1];
            return TarjetaTicket(
              ticket: ticket,
              ruta: p.join(raiz ?? '', ticket.rutaRelativa),
              // TEMPORAL (Fase 12): conteo real bajo demanda.
              elementos: DatosDemo.elementosDe(ticket),
              // Sin lógica todavía: Fase 13 y Fase 14.
              onAbrir: () {},
              onCopiar: () {},
            );
          },
        );
      },
    );
  }
}

class _Pie extends StatelessWidget {
  const _Pie({required this.fechaIndice, required this.totalTickets});

  final DateTime? fechaIndice;
  final int totalTickets;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estilo = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );

    return Material(
      color: tema.colorScheme.surface,
      child: Column(
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: tema.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fechaIndice == null
                        ? Textos.indiceNoGenerado
                        : Textos.indiceActualizado(fechaIndice!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: estilo,
                  ),
                ),
                const SizedBox(width: 16),
                Text(Textos.ticketsIndexados(totalTickets), style: estilo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
