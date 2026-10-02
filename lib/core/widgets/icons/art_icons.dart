import 'dart:ui';

/// Icon geometry: stroked paths, filled paths and the source viewBox.
class ArtIconData {
  const ArtIconData(
    this.strokes, {
    this.fills = const [],
    this.viewBox = const Size(24, 24),
  });

  final List<String> strokes;
  final List<String> fills;
  final Size viewBox;
}

/// Every icon used in the design, transcribed from its SVG markup.
abstract final class ArtIcons {
  static const arrowRight = ArtIconData(['M5 12h14M13 6l6 6-6 6']);
  static const chevronLeft = ArtIconData(['M15 18l-6-6 6-6']);
  static const chevronRight = ArtIconData(['M9 18l6-6-6-6']);
  static const chevronDown = ArtIconData(['M6 9l6 6 6-6']);
  static const close = ArtIconData(['M18 6L6 18M6 6l12 12']);
  static const check = ArtIconData(['M20 6L9 17l-5-5']);
  static const flash = ArtIconData(['M13 2L4 14h7l-1 8 9-12h-7z']);
  static const bookmark = ArtIconData([
    'M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z',
  ]);
  static const expand = ArtIconData([
    'M8 3H5a2 2 0 0 0-2 2v3M21 8V5a2 2 0 0 0-2-2h-3M3 16v3a2 2 0 0 0 2 2h3'
        'M16 21h3a2 2 0 0 0 2-2v-3',
  ]);

  static const _scanCorners =
      'M3 8V6a3 3 0 0 1 3-3h2M16 3h2a3 3 0 0 1 3 3v2M21 16v2a3 3 0 0 1-3 3h-2'
      'M8 21H6a3 3 0 0 1-3-3v-2';
  static const scan = ArtIconData(
    [_scanCorners],
    fills: ['M10.4 12a1.6 1.6 0 1 0 3.2 0a1.6 1.6 0 1 0 -3.2 0'],
  );
  static const scanTab = ArtIconData(
    [_scanCorners],
    fills: ['M10.2 12a1.8 1.8 0 1 0 3.6 0a1.8 1.8 0 1 0 -3.6 0'],
  );

  // — Tab bar —
  static const house = ArtIconData([
    'M3.5 10.2L12 3.5l8.5 6.7V19a1.5 1.5 0 0 1-1.5 1.5H15v-6h-6v6H5'
        'a1.5 1.5 0 0 1-1.5-1.5z',
  ]);
  static const photos = ArtIconData([
    'M5 3.5h14a1.5 1.5 0 0 1 1.5 1.5v14a1.5 1.5 0 0 1-1.5 1.5H5'
        'a1.5 1.5 0 0 1-1.5-1.5V5A1.5 1.5 0 0 1 5 3.5z',
    'M20.5 15.5l-4.5-4.5-9.5 9.5',
    'M7.5 9a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0 -3 0',
  ]);
  static const gallery = ArtIconData([
    'M3 21V9a6 6 0 0 1 12 0v12z',
    'M18 21V12a3 3 0 0 1 3-3',
  ]);
  static const person = ArtIconData([
    'M8 8a4 4 0 1 0 8 0a4 4 0 1 0 -8 0',
    'M4 21c0-4 3.6-6.5 8-6.5s8 2.5 8 6.5',
  ]);

  // — Audio guide —
  static const play = ArtIconData(
    [],
    fills: [
      'M8 5.5v13a1 1 0 0 0 1.5.9l10-6.5a1 1 0 0 0 0-1.7l-10-6.6A1 1 0 0 0 8 5.5z',
    ],
  );
  static const pause = ArtIconData(
    [],
    fills: [
      'M7 5h2a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z',
      'M15 5h2a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1h-2a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z',
    ],
  );
  static const rewind = ArtIconData(['M3 12a9 9 0 1 0 3-6.7L3 8', 'M3 3v5h5']);
  static const forward = ArtIconData([
    'M21 12a9 9 0 1 1-3-6.7L21 8',
    'M21 3v5h-5',
  ]);

  static const apple = ArtIconData(
    [],
    viewBox: Size(17, 20),
    fills: [
      'M14 10.6c0-2.5 2-3.7 2.1-3.8-1.2-1.7-3-1.9-3.6-2-1.5-.2-3 .9-3.8.9'
          '-.8 0-2-.9-3.3-.9C3.7 4.9 2.1 5.9 1.2 7.5c-1.8 3.1-.5 7.8 1.3 10.3'
          '.9 1.2 1.9 2.6 3.2 2.6 1.3-.1 1.8-.8 3.3-.8 1.6 0 2 .8 3.3.8 1.4 0'
          ' 2.3-1.3 3.1-2.5 1-1.4 1.4-2.8 1.4-2.9 0 0-2.8-1-2.8-4.4z'
          'M11.6 3.1c.7-.9 1.2-2 1-3.1-1 0-2.2.7-2.9 1.5-.6.7-1.2 1.9-1 3'
          ' 1.1.1 2.2-.6 2.9-1.4z',
    ],
  );
}
