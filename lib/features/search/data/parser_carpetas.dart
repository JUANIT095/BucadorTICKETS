// Reconocimiento de nombres de carpeta (funciones puras, sin disco).

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/constants/app_constants.dart';

/// true si [error] se refiere a la carpeta que se estaba listando y no a una
/// de sus entradas (en ese caso el listado completo falló).
bool errorDeLaCarpeta(Object error, String carpeta) {
  var ruta = error is FileSystemException ? error.path : null;
  if (ruta == null) return true;
  // En Windows el error del listado trae el patrón de búsqueda: "carpeta\*".
  if (ruta.endsWith(r'\*') || ruta.endsWith('/*')) {
    ruta = ruta.substring(0, ruta.length - 2);
  }
  return p.equals(ruta, carpeta);
}

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

final _inicioDeTicket = RegExp(r'^\s*\d{4,}(\s*[_\-–\s]|\s*$)');

/// Carpeta con aspecto de ticket ("100219_Nombre", "100219 - Nombre",
/// "100219"): al menos 4 dígitos al inicio seguidos de un separador o nada.
bool pareceTicket(String nombre) => _inicioDeTicket.hasMatch(nombre);
