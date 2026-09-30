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
/// carpetas METADA.
class AlmacenamientoPortable {
  AlmacenamientoPortable._(this.carpeta, this.ubicacion);

  /// Ruta de la carpeta de datos; null en modo memoria.
  final String? carpeta;
  final UbicacionDatos ubicacion;

  final _memoria = <String, Map<String, dynamic>>{};

  /// Elige la carpeta de datos: junto al .exe → respaldo → memoria.
  static Future<AlmacenamientoPortable> iniciar({
    required String rutaExe,
    required String? localAppData,
  }) async {
    final principal = p.join(p.dirname(rutaExe), AppConstants.carpetaDatos);
    if (!_dentroDeMetada(principal) && await _esEscribible(principal)) {
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

  static bool _dentroDeMetada(String ruta) =>
      p.split(ruta).any(AppConstants.patronMetada.hasMatch);

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
    final carpeta = this.carpeta;
    if (carpeta == null) return _memoria[nombre];
    try {
      final archivo = File(p.join(carpeta, nombre));
      if (!await archivo.exists()) return null;
      final datos = jsonDecode(await archivo.readAsString());
      return datos is Map<String, dynamic> ? datos : null;
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    }
  }

  /// Escritura atómica: se escribe un `.tmp` y se renombra. Devuelve false si
  /// no se pudo guardar.
  Future<bool> escribirJson(String nombre, Map<String, dynamic> datos) async {
    final carpeta = this.carpeta;
    if (carpeta == null) {
      _memoria[nombre] = datos;
      return true;
    }
    try {
      final destino = p.join(carpeta, nombre);
      final temporal = File('$destino.tmp');
      await temporal.writeAsString(
        const JsonEncoder.withIndent('  ').convert(datos),
        flush: true,
      );
      await temporal.rename(destino);
      return true;
    } on FileSystemException {
      return false;
    }
  }
}
