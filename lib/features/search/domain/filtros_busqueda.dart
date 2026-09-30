/// Filtros de búsqueda; null significa "Todos".
class FiltrosBusqueda {
  const FiltrosBusqueda({this.anio, this.mes});

  final int? anio;

  /// Mes 1–12.
  final int? mes;

  FiltrosBusqueda conAnio(int? anio) => FiltrosBusqueda(anio: anio, mes: mes);

  FiltrosBusqueda conMes(int? mes) => FiltrosBusqueda(anio: anio, mes: mes);
}
