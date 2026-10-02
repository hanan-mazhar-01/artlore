/// "Four details worth a second look" — small counts read better as words.
String numberWord(int n, {bool capitalize = false}) {
  const words = [
    'no',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
  ];
  final w = n >= 0 && n < words.length ? words[n] : '$n';
  return capitalize ? w[0].toUpperCase() + w.substring(1) : w;
}

/// Lower-case roman numerals for editorial lists — i, ii, iii, iv…
String romanNumeral(int n) {
  const values = [10, 9, 5, 4, 1];
  const glyphs = ['x', 'ix', 'v', 'iv', 'i'];
  final out = StringBuffer();
  var rest = n;
  for (var i = 0; i < values.length; i++) {
    while (rest >= values[i]) {
      out.write(glyphs[i]);
      rest -= values[i];
    }
  }
  return out.toString();
}
