// Normalización de texto para comparar sin distinguir mayúsculas ni tildes
// (ARQUITECTURA §5): "Curación" = "curacion" = "CURACION".
//
// Optimizada en la Fase 16: un solo recorrido por las unidades de código, sin
// crear textos intermedios (se ejecuta para cada ticket al indexar y al
// cargar el índice).

/// Letra con tilde (ya en minúscula) → letra base.
final Map<int, int> _sinTilde = {
  for (final (con, sin) in const [
    ('áàäâã', 'a'),
    ('éèëê', 'e'),
    ('íìïî', 'i'),
    ('óòöôõ', 'o'),
    ('úùüû', 'u'),
    ('ñ', 'n'),
    ('ç', 'c'),
  ])
    for (final u in con.codeUnits) u: sin.codeUnitAt(0),
};

/// Diacríticos combinantes U+0300–U+036F (nombres en forma NFD, p. ej.
/// copiados desde un Mac: "o" + tilde aparte).
bool _esCombinante(int u) => u >= 0x300 && u <= 0x36f;

bool _esEspacio(int u) =>
    u == 0x20 ||
    (u >= 0x09 && u <= 0x0d) ||
    u == 0xa0 ||
    u == 0x1680 ||
    (u >= 0x2000 && u <= 0x200a) ||
    u == 0x2028 ||
    u == 0x2029 ||
    u == 0x202f ||
    u == 0x205f ||
    u == 0x3000 ||
    u == 0xfeff;

final _separadores = RegExp(r'[\s_\-–]+');

/// Minúsculas, sin tildes, espacios repetidos colapsados y sin espacios en
/// los extremos.
String normalizar(String texto) {
  final resultado = <int>[];
  var espacioPendiente = false;
  for (final u in texto.toLowerCase().codeUnits) {
    if (_esCombinante(u)) continue;
    if (_esEspacio(u)) {
      espacioPendiente = resultado.isNotEmpty;
      continue;
    }
    if (espacioPendiente) {
      resultado.add(0x20);
      espacioPendiente = false;
    }
    resultado.add(_sinTilde[u] ?? u);
  }
  return String.fromCharCodes(resultado);
}

/// Palabras de [texto] ya normalizadas, separando por espacios, `_`, `-` y `–`.
List<String> palabrasNormalizadas(String texto) => [
  for (final palabra in normalizar(texto).split(_separadores))
    if (palabra.isNotEmpty) palabra,
];
