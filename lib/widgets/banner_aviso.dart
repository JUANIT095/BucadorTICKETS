import 'package:flutter/material.dart';

import '../core/constants/textos.dart';

/// Aviso no bloqueante (raíz no disponible, respaldo en uso, carpetas omitidas…).
class BannerAviso extends StatelessWidget {
  const BannerAviso({super.key, required this.mensaje, this.onCerrar});

  final String mensaje;
  final VoidCallback? onCerrar;

  static const _fondo = Color(0xFFFFF4E0);
  static const _borde = Color(0xFFFFCC80);
  static const _texto = Color(0xFF6D4400);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: _fondo,
        border: Border.all(color: _borde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: _texto),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: _texto),
            ),
          ),
          if (onCerrar != null)
            IconButton(
              onPressed: onCerrar,
              tooltip: Textos.cerrarAviso,
              icon: const Icon(Icons.close_rounded, size: 20),
              color: _texto,
            ),
        ],
      ),
    );
  }
}
