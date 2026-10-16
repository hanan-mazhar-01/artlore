import 'dart:typed_data';

import 'package:artlore/core/media/image_crop.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// A photo whose pixels encode where they are: red grows left → right, green
/// top → bottom. Whatever the frame crops, its mean colour says which part of
/// the photo it was.
Uint8List _photo(int w, int h) {
  final im = img.Image(width: w, height: h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      im.setPixelRgb(x, y, (x * 255 ~/ (w - 1)), (y * 255 ~/ (h - 1)), 0);
    }
  }
  return Uint8List.fromList(img.encodePng(im));
}

void main() {
  test('crop keeps exactly the part under the frame (cover-fitted photo)', () async {
    // A 600×800 photo shown full-screen in a 400×900 view: scaled by height
    // (900/800), so 675 wide, with 137.5px cut off each side.
    final bytes = _photo(600, 800);
    // A frame in the view's top-left quarter-ish area.
    final out = await cropToFrame(
      bytes,
      viewSize: const Size(400, 900),
      frame: const Rect.fromLTWH(100, 100, 200, 200),
    );
    final r = img.decodeImage(out)!;
    // Expected photo region: x = (100 + 137.5)/1.125 .. (300 + 137.5)/1.125,
    // y = 100/1.125 .. 300/1.125  → 211..389 × 89..267 (178×178).
    expect(r.width, closeTo(178, 2));
    expect(r.height, closeTo(178, 2));
    final px = r.getPixel(r.width ~/ 2, r.height ~/ 2);
    // centre of that region: x ≈ 300 → red ≈ 127, y ≈ 178 → green ≈ 57.
    expect(px.r.toInt(), closeTo(127, 6));
    expect(px.g.toInt(), closeTo(57, 6));
  });
}
