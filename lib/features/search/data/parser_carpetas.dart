// Reconocimiento de nombres de carpeta (funciones puras, sin disco).

import '../../../core/constants/app_constants.dart';

/// Año de una carpeta "METADA 2024"; null si el nombre no cumple el patrón.
/// No valida el rango de años (ver [anioEnRango]).
int? anioDeCarpeta(String nombre) {
  final coincidencia = AppConstants.patronMetada.firstMatch(nombre);
  return coincidencia == null ? null : int.parse(coincidencia.group(1)!);
}

bool anioEnRango(int anio) =>
    anio >= AppConstants.anioMinimo && anio <= AppConstants.anioMaximo;

/// Nombre parecido a una carpeta de año que no cumple el patrón
/// ("METADA 2024 (copia)", "METADATA 2025"): se registra como ignorada en
/// lugar de descartarse en silencio.
bool pareceCarpetaMetada(String nombre) =>
    nombre.toLowerCase().contains('metada');
