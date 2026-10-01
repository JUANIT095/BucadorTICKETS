/// Filtros de búsqueda; null significa "Todos".
class FiltrosBusqueda {
  const FiltrosBusqueda({this.anio, this.mes});

  final int? anio;

  /// Mes 1–12.
  final int? mes;

  /// Hay al menos un filtro distinto de "Todos".
  bool get activos => anio != null || mes != null;

  FiltrosBusqueda conAnio(int? anio) => FiltrosBusqueda(anio: anio, mes: mes);

  FiltrosBusqueda conMes(int? mes) => FiltrosBusqueda(anio: anio, mes: mes);
}
