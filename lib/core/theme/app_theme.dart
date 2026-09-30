import 'package:flutter/material.dart';

/// Tema visual de la aplicación (solo claro; el modo oscuro es futuro).
abstract final class AppTheme {
  /// Ancho máximo del contenido central en pantallas anchas.
  static const anchoMaximoContenido = 900.0;

  static const _colorPrincipal = Color(0xFF1F4E79);

  static ThemeData get claro {
    final colores = ColorScheme.fromSeed(seedColor: _colorPrincipal);
    final radio = BorderRadius.circular(12);

    return ThemeData(
      colorScheme: colores,
      scaffoldBackgroundColor: colores.surfaceContainerLow,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colores.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radio,
          side: BorderSide(color: colores.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colores.surface,
        border: OutlineInputBorder(borderRadius: radio),
      ),
      dividerTheme: DividerThemeData(
        color: colores.outlineVariant,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
