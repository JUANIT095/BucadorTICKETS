// Normalización de texto para comparar sin distinguir mayúsculas ni tildes
// (ARQUITECTURA §5): "Curación" = "curacion" = "CURACION".

const _sinTilde = {
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ñ': 'n',
  'ç': 'c',
};

/// Diacríticos combinantes U+0300–U+036F (nombres en forma NFD, p. ej.
/// copiados desde un Mac: "o" + tilde aparte).
final _combinantes = RegExp('[̀-ͯ]');
final _espacios = RegExp(r'\s+');
final _separadores = RegExp(r'[\s_\-–]+');

/// Minúsculas, sin tildes, espacios repetidos colapsados y sin espacios en
/// los extremos.
String normalizar(String texto) {
  final minusculas = texto.toLowerCase().replaceAll(_combinantes, '');
  final buffer = StringBuffer();
  for (final caracter in minusculas.split('')) {
    buffer.write(_sinTilde[caracter] ?? caracter);
  }
  return buffer.toString().replaceAll(_espacios, ' ').trim();
}

/// Palabras de [texto] ya normalizadas, separando por espacios, `_`, `-` y `–`.
List<String> palabrasNormalizadas(String texto) => [
  for (final palabra in normalizar(texto).split(_separadores))
    if (palabra.isNotEmpty) palabra,
];
