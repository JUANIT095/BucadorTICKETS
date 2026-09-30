import 'package:flutter/material.dart';

import '../../../../core/constants/textos.dart';
import '../../domain/filtros_busqueda.dart';

/// Selectores compactos de año y mes.
class PanelFiltros extends StatelessWidget {
  const PanelFiltros({
    super.key,
    required this.anios,
    required this.filtros,
    required this.onCambio,
    this.habilitado = true,
  });

  final List<int> anios;
  final FiltrosBusqueda filtros;
  final ValueChanged<FiltrosBusqueda> onCambio;
  final bool habilitado;

  /// Valor de la opción "Todos" en los menús (null no es seleccionable).
  static const _todos = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownMenu<int>(
          // Se recrea cuando cambian los años o la selección, para que el
          // texto mostrado siga siempre al filtro (p. ej. vuelta a "Todos").
          key: ValueKey('${anios.join(',')}|${filtros.anio}'),
          width: 124,
          label: const Text(Textos.filtroAnio),
          initialSelection: filtros.anio ?? _todos,
          requestFocusOnTap: false,
          enabled: habilitado,
          dropdownMenuEntries: [
            const DropdownMenuEntry(value: _todos, label: Textos.todos),
            for (final anio in anios)
              DropdownMenuEntry(value: anio, label: '$anio'),
          ],
          onSelected: (valor) =>
              onCambio(filtros.conAnio(valor == _todos ? null : valor)),
        ),
        const SizedBox(width: 12),
        DropdownMenu<int>(
          width: 160,
          label: const Text(Textos.filtroMes),
          initialSelection: filtros.mes ?? _todos,
          requestFocusOnTap: false,
          enabled: habilitado,
          dropdownMenuEntries: [
            const DropdownMenuEntry(value: _todos, label: Textos.todos),
            for (var mes = 1; mes <= 12; mes++)
              DropdownMenuEntry(value: mes, label: Textos.meses[mes - 1]),
          ],
          onSelected: (valor) =>
              onCambio(filtros.conMes(valor == _todos ? null : valor)),
        ),
      ],
    );
  }
}
