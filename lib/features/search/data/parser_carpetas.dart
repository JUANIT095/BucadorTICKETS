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

/// Año de una carpeta de año ("2024" o "METADA 2024"); null si el nombre no
/// cumple ninguno de los dos formatos. No valida el rango (ver [anioEnRango]).
int? anioDeCarpeta(String nombre) {
  final coincidencia =
      AppConstants.patronAnioSolo.firstMatch(nombre) ??
      AppConstants.patronMetada.firstMatch(nombre);
  return coincidencia == null ? null : int.parse(coincidencia.group(1)!);
}

bool anioEnRango(int anio) =>
    anio >= AppConstants.anioMinimo && anio <= AppConstants.anioMaximo;

final _empiezaConAnio = RegExp(r'^\s*(\d{4})(?!\d)');

/// Nombre parecido a una carpeta de año que no cumple el formato
/// ("2024 (copia)", "2024_viejo", "METADA 2024 (copia)", "METADATA 2025"):
/// se registra como ignorada en lugar de descartarse en silencio.
bool pareceCarpetaAnio(String nombre) {
  if (nombre.toLowerCase().contains('metada')) return true;
  final anio = _empiezaConAnio.firstMatch(nombre);
  return anio != null && anioEnRango(int.parse(anio.group(1)!));
}

/// Número + separador (`_`, `-`, `–` o espacios) + resto.
final _numeroYNombre = RegExp(r'^\s*(\d+)(?:\s*[_\-–]+\s*|\s+|\s*$)(.*)$');

/// Número y nombre de una carpeta de ticket (ARQUITECTURA §9):
/// - "100219_Curación2 ABC - Proyecto IA" → 100219 / "Curación2 ABC - Proyecto IA"
/// - "101045 - Rediseño", "101045-Rediseño", "101045 Rediseño" → 101045 / "Rediseño"
/// - "100219_ABC_v2" → corta solo en el primer separador → "ABC_v2"
/// - "100219" → nombre vacío
/// - "Varios" o "123abc" (sin separador) → sin número, nombre = carpeta
({String? numero, String nombre}) numeroYNombreDeTicket(String carpeta) {
  final coincidencia = _numeroYNombre.firstMatch(carpeta);
  if (coincidencia == null) return (numero: null, nombre: carpeta.trim());
  return (
    numero: coincidencia.group(1)!,
    nombre: coincidencia.group(2)!.trim(),
  );
}

final _inicioDeTicket = RegExp(r'^\s*\d{4,}(\s*[_\-–\s]|\s*$)');

/// Carpeta con aspecto de ticket ("100219_Nombre", "100219 - Nombre",
/// "100219"): al menos 4 dígitos al inicio seguidos de un separador o nada.
bool pareceTicket(String nombre) => _inicioDeTicket.hasMatch(nombre);
