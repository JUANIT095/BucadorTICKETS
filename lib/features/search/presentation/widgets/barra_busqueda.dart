import 'package:flutter/material.dart';

import '../../../../core/constants/textos.dart';
import '../../../../core/theme/app_theme.dart';

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
  final _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    // Redibuja para animar el brillo del campo al ganar/perder el foco.
    _foco.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _texto.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _buscar() => widget.onBuscar(_texto.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (_foco.hasFocus)
                  BoxShadow(
                    color: AppTheme.rojo.withValues(alpha: 0.35),
                    blurRadius: 18,
                  ),
              ],
            ),
            child: TextField(
              controller: _texto,
              focusNode: _foco,
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
        ),
        if (widget.filtros != null) ...[
          const SizedBox(width: 12),
          widget.filtros!,
        ],
        const SizedBox(width: 12),
        _BotonBuscar(onPressed: _buscar),
      ],
    );
  }
}

/// Botón con degradado rojo que se aclara y brilla al pasar el mouse.
class _BotonBuscar extends StatefulWidget {
  const _BotonBuscar({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_BotonBuscar> createState() => _BotonBuscarState();
}

class _BotonBuscarState extends State<_BotonBuscar> {
  var _encima = false;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(12);

    return MouseRegion(
      onEnter: (_) => setState(() => _encima = true),
      onExit: (_) => setState(() => _encima = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: radio,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _encima
                ? const [AppTheme.rojoHover, AppTheme.rojo]
                : const [AppTheme.rojo, AppTheme.rojoProfundo],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.rojo.withValues(alpha: _encima ? 0.45 : 0.2),
              blurRadius: _encima ? 22 : 12,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: radio,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Center(
                widthFactor: 1,
                child: Text(
                  Textos.buscar,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.blanco,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
