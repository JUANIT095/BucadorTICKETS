import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/textos.dart';
import '../../../core/services/acciones_sistema.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ticket.dart';
import '../../../widgets/banner_aviso.dart';
import '../../../widgets/fondo_animado.dart';
import '../../../widgets/panel_vidrio.dart';
import 'buscador_controller.dart';
import 'raiz_controller.dart';
import 'widgets/barra_busqueda.dart';
import 'widgets/panel_filtros.dart';
import 'widgets/tarjeta_ticket.dart';
import 'widgets/vista_estado.dart';
import 'widgets/vista_raiz.dart';

/// Pantalla principal de búsqueda.
class PantallaBusqueda extends StatelessWidget {
  const PantallaBusqueda({
    super.key,
    required this.controller,
    required this.raiz,
  });

  final BuscadorController controller;
  final RaizController raiz;

  /// "Actualizar índice": con raíz activa, vuelve a indexar. Sin conexión,
  /// primero reintenta encontrar la raíz (p. ej. el disco se volvió a
  /// conectar) y, si aparece, indexa.
  Future<void> _actualizarIndice() async {
    final activa = raiz.rutaActiva;
    if (activa != null) return controller.actualizarIndice(activa);
    await raiz.reintentar();
    final recuperada = raiz.rutaActiva;
    if (recuperada != null) await controller.actualizarIndice(recuperada);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, raiz]),
      builder: (context, _) {
        // Raíz con la que se trabaja: la activa o, sin conexión, la última
        // conocida (se busca en el índice guardado).
        final rutaRaiz =
            raiz.rutaActiva ??
            switch (raiz.estado) {
              RaizNoEncontrada(:final ultimaRuta) when controller.sinConexion =>
                ultimaRuta,
              _ => null,
            };
        final hayRaiz = rutaRaiz != null;
        return Scaffold(
          body: FondoAnimado(
            child: Column(
              children: [
                _Encabezado(
                  raiz: rutaRaiz,
                  onCambiarCarpeta: raiz.ocupado ? null : raiz.elegirCarpeta,
                  onActualizarIndice:
                      hayRaiz && !controller.indexando && !raiz.ocupado
                      ? _actualizarIndice
                      : null,
                ),
                _Centrado(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    children: [
                      PanelVidrio(
                        padding: const EdgeInsets.all(12),
                        child: BarraBusqueda(
                          onBuscar: controller.buscar,
                          habilitada: hayRaiz,
                          filtros: PanelFiltros(
                            anios: controller.anios,
                            filtros: controller.filtros,
                            onCambio: controller.cambiarFiltros,
                            habilitado: hayRaiz,
                          ),
                        ),
                      ),
                      for (final aviso in raiz.avisos)
                        _Aviso(aviso, () => raiz.descartarAviso(aviso)),
                      for (final aviso in controller.avisos)
                        _Aviso(aviso, () => controller.descartarAviso(aviso)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _ContenidoAnimado(
                    controller: controller,
                    raiz: raiz,
                    rutaRaiz: rutaRaiz,
                  ),
                ),
                _Pie(
                  fechaIndice: controller.fechaIndice,
                  totalTickets: controller.totalTickets,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.mensaje, this.onCerrar);

  final String mensaje;
  final VoidCallback onCerrar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: BannerAviso(mensaje: mensaje, onCerrar: onCerrar),
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
  const _Encabezado({
    required this.raiz,
    required this.onCambiarCarpeta,
    required this.onActualizarIndice,
  });

  final String? raiz;

  /// Null mientras se verifica la carpeta.
  final VoidCallback? onCambiarCarpeta;

  /// Null sin raíz o mientras se indexa.
  final VoidCallback? onActualizarIndice;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final textoRaiz = raiz ?? Textos.sinCarpeta;

    return PanelVidrio(
      radio: 0,
      borde: const Border(bottom: BorderSide(color: AppTheme.bordeVidrio)),
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
                TextButton.icon(
                  onPressed: onCambiarCarpeta,
                  icon: const Icon(Icons.drive_folder_upload_outlined),
                  label: const Text(Textos.cambiarCarpeta),
                ),
                TextButton.icon(
                  onPressed: onActualizarIndice,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(Textos.actualizarIndice),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cambia entre estados con un fundido y un leve deslizamiento hacia arriba.
class _ContenidoAnimado extends StatelessWidget {
  const _ContenidoAnimado({
    required this.controller,
    required this.raiz,
    required this.rutaRaiz,
  });

  final BuscadorController controller;
  final RaizController raiz;

  /// Raíz activa o, sin conexión, la última conocida; null = sin raíz.
  final String? rutaRaiz;

  @override
  Widget build(BuildContext context) {
    final estadoRaiz = raiz.estado;
    final estado = controller.estado;
    final ruta = rutaRaiz;
    final (Object clave, Widget contenido) = estadoRaiz is RaizVerificando
        ? (RaizVerificando, const VistaEstado.verificandoCarpeta())
        : ruta != null
        ? (
            estado is EstadoConResultados ? estado.tickets : estado.runtimeType,
            switch (estado) {
              EstadoInicial() => const VistaEstado.inicial(),
              EstadoBuscando() => const VistaEstado.buscando(),
              EstadoIndexando() => const VistaEstado.indexando(),
              EstadoSinResultados() => const VistaEstado.sinResultados(),
              EstadoError(:final mensaje) => VistaEstado.error(
                mensaje: mensaje,
              ),
              EstadoConResultados(:final tickets, :final total) =>
                _ListaResultados(
                  tickets: tickets,
                  total: total,
                  raiz: ruta,
                  elementosDe: controller.elementosDe,
                  abrirCarpeta: controller.abrirCarpeta,
                ),
            },
          )
        : (estadoRaiz.runtimeType, VistaRaiz(controller: raiz));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (actual, anteriores) =>
          Stack(fit: StackFit.expand, children: [...anteriores, ?actual]),
      transitionBuilder: (hijo, animacion) => FadeTransition(
        opacity: animacion,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(animacion),
          child: hijo,
        ),
      ),
      child: KeyedSubtree(key: ObjectKey(clave), child: contenido),
    );
  }
}

class _ListaResultados extends StatelessWidget {
  const _ListaResultados({
    required this.tickets,
    required this.total,
    required this.raiz,
    required this.elementosDe,
    required this.abrirCarpeta,
  });

  final List<Ticket> tickets;

  /// Coincidencias totales (mayor que `tickets.length` si se recortó).
  final int total;
  final String raiz;

  /// Conteo de elementos; la lista solo construye las tarjetas visibles, así
  /// que solo se cuentan esas.
  final Future<int?> Function(Ticket ticket, String raiz) elementosDe;

  final Future<ResultadoAbrir> Function(Ticket ticket, String raiz)
  abrirCarpeta;

  /// Abre el ticket; si no se pudo (o se abrió otra carpeta), lo explica en
  /// un mensaje breve.
  Future<void> _abrir(BuildContext context, Ticket ticket) async {
    final mensaje = switch (await abrirCarpeta(ticket, raiz)) {
      CarpetaAbierta() => null,
      CarpetaCercanaAbierta(:final ruta) => Textos.carpetaCercanaAbierta(ruta),
      TicketNoEncontrado() => Textos.ticketNoEncontrado,
      UnidadNoDisponible() => Textos.unidadNoDisponible,
      ErrorAlAbrir() => Textos.errorAlAbrir,
    };
    if (mensaje == null || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

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
                total > tickets.length
                    ? Textos.resultadosLimitados(tickets.length, total)
                    : Textos.resultados(total),
                style: tema.textTheme.labelLarge?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              );
            }
            final ticket = tickets[i - 1];
            return _EntradaEscalonada(
              indice: i - 1,
              child: TarjetaTicket(
                ticket: ticket,
                ruta: ticket.rutaEn(raiz),
                elementos: elementosDe(ticket, raiz),
                onAbrir: () => _abrir(context, ticket),
                // Sin lógica todavía: Fase 14.
                onCopiar: () {},
              ),
            );
          },
        );
      },
    );
  }
}

/// Aparición escalonada desde abajo; solo las primeras tarjetas se animan
/// para no retrasar listas largas.
class _EntradaEscalonada extends StatelessWidget {
  const _EntradaEscalonada({required this.indice, required this.child});

  static const _maxAnimadas = 10;
  static const _duracionMs = 300;
  static const _retrasoMs = 50;

  final int indice;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (indice >= _maxAnimadas) return child;

    final retraso = indice * _retrasoMs;
    final total = _duracionMs + retraso;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(retraso / total, 1, curve: Curves.easeOutCubic),
      builder: (context, valor, hijo) => Opacity(
        opacity: valor,
        child: Transform.translate(
          offset: Offset(0, (1 - valor) * 16),
          child: hijo,
        ),
      ),
      child: child,
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

    return PanelVidrio(
      radio: 0,
      borde: const Border(top: BorderSide(color: AppTheme.bordeVidrio)),
      child: Column(
        children: [
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
