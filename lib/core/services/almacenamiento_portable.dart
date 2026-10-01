import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants/app_constants.dart';

enum UbicacionDatos {
  /// `<carpeta del .exe>\data_usuario\`.
  principal,

  /// `%LOCALAPPDATA%\BuscadorTickets\`.
  respaldo,

  /// No se pudo escribir en ningún lugar: los datos no se conservan.
  memoria,
}

/// Carpeta de datos portable (configuración e índice) y lectura/escritura
/// de JSON en UTF-8.
///
/// Solo escribe en su propia carpeta de datos; nunca en la raíz ni en
/// carpetas de año.
class AlmacenamientoPortable {
  AlmacenamientoPortable._(this.carpeta, this.ubicacion);

  /// Ruta de la carpeta de datos; null en modo memoria.
  final String? carpeta;
  final UbicacionDatos ubicacion;

  final _memoria = <String, String>{};

  /// Elige la carpeta de datos: junto al .exe → respaldo → memoria.
  static Future<AlmacenamientoPortable> iniciar({
    required String rutaExe,
    required String? localAppData,
  }) async {
    final principal = p.join(p.dirname(rutaExe), AppConstants.carpetaDatos);
    if (!_dentroDeCarpetaAnio(principal) && await _esEscribible(principal)) {
      return AlmacenamientoPortable._(principal, UbicacionDatos.principal);
    }
    if (localAppData != null && localAppData.isNotEmpty) {
      final respaldo = p.join(localAppData, AppConstants.carpetaRespaldo);
      if (await _esEscribible(respaldo)) {
        return AlmacenamientoPortable._(respaldo, UbicacionDatos.respaldo);
      }
    }
    return AlmacenamientoPortable._(null, UbicacionDatos.memoria);
  }

  static bool _dentroDeCarpetaAnio(String ruta) =>
      p.split(ruta).any(AppConstants.esNombreDeAnio);

  static Future<bool> _esEscribible(String carpeta) async {
    try {
      await Directory(carpeta).create(recursive: true);
      final prueba = File(p.join(carpeta, '.prueba_escritura'));
      await prueba.writeAsString('ok', flush: true);
      await prueba.delete();
      return true;
    } on FileSystemException {
      return false;
    }
  }

  /// Devuelve null si el archivo no existe, no se puede leer o no es un
  /// objeto JSON válido.
  Future<Map<String, dynamic>?> leerJson(String nombre) async {
    final texto = await leerTexto(nombre);
    if (texto == null) return null;
    try {
      final datos = jsonDecode(texto);
      return datos is Map<String, dynamic> ? datos : null;
    } on FormatException {
      return null;
    }
  }

  Future<bool> escribirJson(String nombre, Map<String, dynamic> datos) =>
      escribirTexto(nombre, const JsonEncoder.withIndent('  ').convert(datos));

  /// Contenido UTF-8 del archivo; null si no existe o no se puede leer.
  Future<String?> leerTexto(String nombre) async {
    final carpeta = this.carpeta;
    if (carpeta == null) return _memoria[nombre];
    try {
      final archivo = File(p.join(carpeta, nombre));
      if (!await archivo.exists()) return null;
      return await archivo.readAsString();
    } on FileSystemException {
      return null;
    }
  }

  /// Escritura atómica: se escribe un `.tmp` y se renombra. Devuelve false si
  /// no se pudo guardar.
  Future<bool> escribirTexto(String nombre, String contenido) async {
    final carpeta = this.carpeta;
    if (carpeta == null) {
      _memoria[nombre] = contenido;
      return true;
    }
    try {
      final destino = p.join(carpeta, nombre);
      final temporal = File('$destino.tmp');
      await temporal.writeAsString(contenido, flush: true);
      await temporal.rename(destino);
      return true;
    } on FileSystemException {
      return false;
    }
  }
}
