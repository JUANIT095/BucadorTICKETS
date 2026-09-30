import 'package:flutter/material.dart';

import '../../../../core/constants/textos.dart';

/// Campo de búsqueda + botón BUSCAR. Enter también busca.
class BarraBusqueda extends StatefulWidget {
  const BarraBusqueda({super.key, required this.onBuscar, this.filtros});

  final ValueChanged<String> onBuscar;

  /// Se muestra entre el campo y el botón.
  final Widget? filtros;

  @override
  State<BarraBusqueda> createState() => _BarraBusquedaState();
}

class _BarraBusquedaState extends State<BarraBusqueda> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _buscar() => widget.onBuscar(_texto.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _texto,
            autofocus: true,
            textInputAction: TextInputAction.search,
            // Vacío a propósito: evita que Enter quite el foco del campo,
            // así se pueden encadenar búsquedas.
            onEditingComplete: () {},
            onSubmitted: (_) => _buscar(),
            style: Theme.of(context).textTheme.titleMedium,
            decoration: const InputDecoration(
              hintText: Textos.pistaBusqueda,
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        if (widget.filtros != null) ...[
          const SizedBox(width: 12),
          widget.filtros!,
        ],
        const SizedBox(width: 12),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _buscar,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(Textos.buscar),
          ),
        ),
      ],
    );
  }
}
