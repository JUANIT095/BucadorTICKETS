import 'package:flutter/material.dart';

/// Tema visual: fondo negro, texto blanco y acentos rojos, con paneles de
/// vidrio difuminado. Es el único tema de la aplicación.
abstract final class AppTheme {
  /// Ancho máximo del contenido central en pantallas anchas.
  static const anchoMaximoContenido = 900.0;

  // Paleta
  static const negro = Color(0xFF0B0B0D);
  static const blanco = Color(0xFFF5F5F7);
  static const grisTexto = Color(0xFFA1A1AA);
  static const rojo = Color(0xFFE11D2E);
  static const rojoHover = Color(0xFFFF3B4E);
  static const rojoProfundo = Color(0xFF7A0E18);

  // Vidrio (blanco translúcido sobre el fondo)
  static const vidrio = Color(0x12FFFFFF);
  static const vidrioResaltado = Color(0x1FFFFFFF);
  static const bordeVidrio = Color(0x1AFFFFFF);
  static const superficieMenu = Color(0xFF18181B);

  static const desenfoqueVidrio = 18.0;

  static ThemeData get oscuro {
    final colores = const ColorScheme.dark(
      primary: rojo,
      onPrimary: blanco,
      primaryContainer: rojoProfundo,
      onPrimaryContainer: blanco,
      secondary: rojo,
      onSecondary: blanco,
      error: rojoHover,
      onError: blanco,
      surface: negro,
      onSurface: blanco,
      onSurfaceVariant: grisTexto,
      outline: Color(0x4DFFFFFF),
      outlineVariant: bordeVidrio,
    );
    final radio = BorderRadius.circular(12);
    final bordeCampo = OutlineInputBorder(
      borderRadius: radio,
      borderSide: const BorderSide(color: bordeVidrio),
    );
    final estiloMenu = MenuStyle(
      backgroundColor: const WidgetStatePropertyAll(superficieMenu),
      side: const WidgetStatePropertyAll(BorderSide(color: bordeVidrio)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: radio),
      ),
    );

    return ThemeData(
      colorScheme: colores,
      scaffoldBackgroundColor: negro,
      canvasColor: superficieMenu,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: vidrio,
        hintStyle: const TextStyle(color: grisTexto),
        labelStyle: const TextStyle(color: grisTexto),
        prefixIconColor: WidgetStateColor.resolveWith(
          (estados) => estados.contains(WidgetState.focused) ? rojo : grisTexto,
        ),
        border: bordeCampo,
        enabledBorder: bordeCampo,
        focusedBorder: OutlineInputBorder(
          borderRadius: radio,
          borderSide: const BorderSide(color: rojo, width: 1.5),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(menuStyle: estiloMenu),
      menuTheme: MenuThemeData(style: estiloMenu),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: rojo,
        selectionColor: Color(0x66E11D2E),
        selectionHandleColor: rojo,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: rojo,
          foregroundColor: blanco,
          shape: RoundedRectangleBorder(borderRadius: radio),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: blanco,
          side: const BorderSide(color: Color(0x4DFFFFFF)),
          shape: RoundedRectangleBorder(borderRadius: radio),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: blanco),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: rojo,
        foregroundColor: blanco,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: superficieMenu,
          border: Border.all(color: bordeVidrio),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: blanco, fontSize: 12),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(Color(0x40FFFFFF)),
      ),
      dividerTheme: const DividerThemeData(
        color: bordeVidrio,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
