// Reconocimiento de carpetas de mes (funciones puras, sin disco).

/// Nombres completos y variantes → número de mes.
const _nombres = {
  'enero': 1,
  'febrero': 2,
  'marzo': 3,
  'abril': 4,
  'mayo': 5,
  'junio': 6,
  'julio': 7,
  'agosto': 8,
  'septiembre': 9,
  'setiembre': 9,
  'octubre': 10,
  'noviembre': 11,
  'diciembre': 12,
};

/// Abreviaturas habituales.
const _abreviaturas = {
  'ene': 1,
  'feb': 2,
  'mar': 3,
  'abr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'ago': 8,
  'sep': 9,
  'sept': 9,
  'set': 9,
  'oct': 10,
  'nov': 11,
  'dic': 12,
};

final _palabras = RegExp(r'[a-záéíóúüñ]+');

/// Solo número: "05", "5", "05-2024", "2024_05" (el año de 4 dígitos se omite).
final _soloNumero = RegExp(
  r'^\s*(?:(\d{1,2})|(\d{1,2})\s*[-_. ]\s*\d{4}|\d{4}\s*[-_. ]\s*(\d{1,2}))\s*$',
);

/// Mes 1–12 de una carpeta de mes; null si no se reconoce.
///
/// Acepta nombres con cualquier combinación de mayúsculas ("MAYO"),
/// "Setiembre", abreviaturas ("Sep"), prefijos de 3+ letras ("Sept", "Novi"),
/// nombre con número o año ("05 Mayo", "05-Mayo", "Mayo 2024") y número solo
/// ("05"). Si el nombre y el número no coinciden, manda el nombre. Varios
/// meses distintos en el nombre ("Enero-Febrero") ⇒ null.
int? mesDeCarpeta(String nombre) {
  final minusculas = nombre.toLowerCase();
  final porNombre = {
    for (final palabra in _palabras.allMatches(minusculas))
      ?_mesDePalabra(palabra.group(0)!),
  };
  if (porNombre.length == 1) return porNombre.single;
  if (porNombre.length > 1) return null;

  final numero = _soloNumero.firstMatch(minusculas);
  if (numero == null) return null;
  final mes = int.parse(numero.group(1) ?? numero.group(2) ?? numero.group(3)!);
  return mes >= 1 && mes <= 12 ? mes : null;
}

int? _mesDePalabra(String palabra) {
  final exacto = _nombres[palabra] ?? _abreviaturas[palabra];
  if (exacto != null) return exacto;
  if (palabra.length < 3) return null;
  for (final MapEntry(key: nombre, value: mes) in _nombres.entries) {
    if (nombre.startsWith(palabra)) return mes;
  }
  return null;
}
