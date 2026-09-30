import 'package:flutter/material.dart';

import '../core/constants/textos.dart';
import '../core/theme/app_theme.dart';
import 'panel_vidrio.dart';

/// Aviso no bloqueante (raíz no disponible, respaldo en uso, carpetas omitidas…).
class BannerAviso extends StatelessWidget {
  const BannerAviso({super.key, required this.mensaje, this.onCerrar});

  final String mensaje;
  final VoidCallback? onCerrar;

  @override
  Widget build(BuildContext context) {
    return PanelVidrio(
      radio: 12,
      borde: Border.all(color: AppTheme.rojo.withValues(alpha: 0.6)),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.rojo),
          const SizedBox(width: 12),
          Expanded(
            child: Text(mensaje, style: Theme.of(context).textTheme.bodyMedium),
          ),
          if (onCerrar != null)
            IconButton(
              onPressed: onCerrar,
              tooltip: Textos.cerrarAviso,
              icon: const Icon(Icons.close_rounded, size: 20),
              color: AppTheme.grisTexto,
            ),
        ],
      ),
    );
  }
}
