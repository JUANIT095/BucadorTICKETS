import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Panel de vidrio esmerilado: difumina lo que hay detrás.
///
/// Usar solo en paneles fijos (encabezado, búsqueda, pie, avisos): el
/// desenfoque es costoso para repetirlo en cada elemento de una lista.
class PanelVidrio extends StatelessWidget {
  const PanelVidrio({
    super.key,
    required this.child,
    this.radio = 16,
    this.borde,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double radio;

  /// Por defecto, borde fino blanco translúcido en los cuatro lados.
  final BoxBorder? borde;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final forma = BorderRadius.circular(radio);
    return ClipRRect(
      borderRadius: forma,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppTheme.desenfoqueVidrio,
          sigmaY: AppTheme.desenfoqueVidrio,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.vidrio,
            borderRadius: forma,
            border: borde ?? Border.all(color: AppTheme.bordeVidrio),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
