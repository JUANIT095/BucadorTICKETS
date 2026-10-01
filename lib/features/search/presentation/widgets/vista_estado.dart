import 'package:flutter/material.dart';

import '../../../../core/constants/textos.dart';

/// Vista centrada para los estados sin resultados que mostrar.
class VistaEstado extends StatelessWidget {
  const VistaEstado({
    super.key,
    required this.titulo,
    this.detalle,
    this.icono,
    this.cargando = false,
    this.esError = false,
  });

  const VistaEstado.inicial({super.key})
    : titulo = Textos.estadoInicial,
      detalle = Textos.estadoInicialDetalle,
      icono = Icons.manage_search_rounded,
      cargando = false,
      esError = false;

  const VistaEstado.buscando({super.key})
    : titulo = Textos.estadoBuscando,
      detalle = null,
      icono = null,
      cargando = true,
      esError = false;

  const VistaEstado.indexando({super.key})
    : titulo = Textos.estadoIndexando,
      detalle = Textos.estadoIndexandoDetalle,
      icono = null,
      cargando = true,
      esError = false;

  const VistaEstado.verificandoCarpeta({super.key})
    : titulo = Textos.verificandoCarpeta,
      detalle = null,
      icono = null,
      cargando = true,
      esError = false;

  const VistaEstado.sinResultados({super.key, bool conFiltros = false})
    : titulo = Textos.sinResultados,
      detalle = conFiltros
          ? Textos.sinResultadosConFiltros
          : Textos.sinResultadosDetalle,
      icono = Icons.search_off_rounded,
      cargando = false,
      esError = false;

  const VistaEstado.error({super.key, required String mensaje})
    : titulo = Textos.estadoError,
      detalle = mensaje,
      icono = Icons.error_outline_rounded,
      cargando = false,
      esError = true;

  final String titulo;
  final String? detalle;
  final IconData? icono;
  final bool cargando;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cargando)
              const SizedBox.square(
                dimension: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else if (icono != null)
              Icon(
                icono,
                size: 56,
                color: esError ? colores.error : colores.outline,
              ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleLarge,
            ),
            if (detalle != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Text(
                  detalle!,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: colores.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
