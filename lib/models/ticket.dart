import 'package:path/path.dart' as p;

import '../core/utils/normalizador.dart';

final _cerosIniciales = RegExp(r'^0+(?=\d)');

/// Carpeta de ticket: la unidad de búsqueda.
///
/// Los campos `...Norm` y [palabras] se calculan al construir el ticket y no
/// se guardan en el índice: sirven para buscar sin distinguir mayúsculas ni
/// tildes sin recalcularlos en cada búsqueda.
class Ticket {
  Ticket({
    this.numero,
    required this.nombre,
    required this.nombreCarpeta,
    required this.anio,
    this.mes,
    required this.carpetaMes,
    required this.rutaRelativa,
  }) : numeroNorm = numero ?? '',
       numeroOrden = numero?.replaceFirst(_cerosIniciales, ''),
       nombreNorm = normalizar(nombre),
       carpetaNorm = normalizar(nombreCarpeta),
       palabras = palabrasNormalizadas(nombreCarpeta);

  /// Número como texto (conserva ceros); null si la carpeta no empieza por número.
  final String? numero;

  /// Nombre sin el número: "Curación2 ABC - Proyecto IA".
  final String nombre;

  /// Nombre completo de la carpeta: "100219_Curación2 ABC - Proyecto IA".
  final String nombreCarpeta;

  final int anio;

  /// Mes 1–12; null si la carpeta de mes no se reconoce o no hay mes.
  final int? mes;

  /// Nombre original de la carpeta de mes, para mostrar; vacío si el ticket
  /// está guardado directamente en la carpeta del año (sin mes).
  final String carpetaMes;

  /// Ruta relativa a la carpeta raíz (identifica al ticket).
  final String rutaRelativa;

  // Solo en memoria
  final String numeroNorm;
  final String nombreNorm;
  final String carpetaNorm;

  /// Número sin ceros a la izquierda, para ordenar numéricamente sin
  /// convertir a entero (los números pueden ser largos); null sin número.
  final String? numeroOrden;

  /// Palabras normalizadas del nombre completo de la carpeta.
  final List<String> palabras;

  /// Ruta absoluta para una raíz concreta (la raíz puede cambiar de letra).
  String rutaEn(String raiz) => p.join(raiz, rutaRelativa);

  /// Formato del índice (ARQUITECTURA §4). `nombreCarpeta` no se guarda: es
  /// el último tramo de `ruta`.
  Map<String, dynamic> aJson() => {
    if (numero != null) 'numero': numero,
    'nombre': nombre,
    'anio': anio,
    if (mes != null) 'mes': mes,
    'carpetaMes': carpetaMes,
    'ruta': rutaRelativa,
  };

  /// Null si la entrada está incompleta o tiene tipos inválidos: un registro
  /// dañado del índice se descarta sin romper la carga del resto.
  static Ticket? desdeJson(Object? json) {
    if (json is! Map) return null;
    final numero = json['numero'];
    final nombre = json['nombre'];
    final anio = json['anio'];
    final mes = json['mes'];
    final carpetaMes = json['carpetaMes'];
    final ruta = json['ruta'];
    if (nombre is! String ||
        anio is! int ||
        carpetaMes is! String ||
        ruta is! String ||
        ruta.trim().isEmpty ||
        (numero != null && numero is! String) ||
        (mes != null && (mes is! int || mes < 1 || mes > 12))) {
      return null;
    }
    return Ticket(
      numero: numero as String?,
      nombre: nombre,
      nombreCarpeta: p.basename(ruta),
      anio: anio,
      mes: mes as int?,
      carpetaMes: carpetaMes,
      rutaRelativa: ruta,
    );
  }

  /// Dos tickets son el mismo si están en la misma ruta (Windows no distingue
  /// mayúsculas en rutas). El número puede repetirse en otro mes o año.
  @override
  bool operator ==(Object other) =>
      other is Ticket &&
      other.rutaRelativa.toLowerCase() == rutaRelativa.toLowerCase();

  @override
  int get hashCode => rutaRelativa.toLowerCase().hashCode;

  @override
  String toString() => 'Ticket($rutaRelativa)';
}
