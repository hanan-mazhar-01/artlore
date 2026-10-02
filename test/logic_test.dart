import 'package:artlore/core/utils/date_labels.dart';
import 'package:artlore/core/utils/number_words.dart';
import 'package:artlore/core/widgets/icons/svg_path.dart';
import 'package:artlore/features/artwork/data/mock_detective_repository.dart';
import 'package:artlore/features/artwork/presentation/detective/detective_controller.dart';
import 'package:artlore/features/artwork/presentation/look_closer/look_closer_camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LookCloserCamera', () {
    const camera = LookCloserCamera(viewport: Size(390, 620), aspect: 1.25);

    test('overview centres a canvas that fills the height', () {
      expect(camera.canvas, const Size(775, 620));
      final m = camera.overview();
      expect(m.getTranslation().x, closeTo((390 - 775) / 2, .01));
      expect(m.getMaxScaleOnAxis(), 1);
    });

    test('focus zooms 1.6× and keeps the canvas covering the viewport', () {
      final m = camera.focus(.88, .13); // top-right moon
      final t = m.getTranslation();
      expect(m.getMaxScaleOnAxis(), closeTo(1.6, .001));
      expect(t.x, lessThanOrEqualTo(0));
      expect(t.x, greaterThanOrEqualTo(390 - 775 * 1.6 - .01));
      expect(t.y, lessThanOrEqualTo(0));
    });
  });

  group('Detective', () {
    test('a tap on the target is found, a far tap misses', () async {
      final cases = await const MockDetectiveRepository().fetchCases();
      final wave = cases.first;
      const box = Size(358, 244);
      final target = DetectiveController.targetIn(wave, box, 1.488);
      // Cover-fit: the image is wider than the box and cropped equally.
      const w = 244 * 1.488;
      expect(target.dx, closeTo((box.width - w) / 2 + .63 * w, .01));
      final d = (target - const Offset(20, 20)).distance;
      expect(d, greaterThan(box.height * .15));
    });

    test('hints escalate with misses', () async {
      final c = (await const MockDetectiveRepository().fetchCases()).first;
      expect(c.hintFor(0), c.hints[0]);
      expect(c.hintFor(2), c.hints[1]);
      expect(c.hintFor(5), c.hints[2]);
    });
  });

  test('svg paths parse arcs, relative commands and closes', () {
    final p = SvgPath.parse('M3 8V6a3 3 0 0 1 3-3h2M10 10l4 4z');
    final b = p.getBounds();
    expect(b.left, closeTo(3, .01));
    expect(b.top, closeTo(3, .01));
    expect(b.right, closeTo(14, .01));
  });

  test('editorial dates', () {
    final now = DateTime(2026, 10, 1, 18);
    expect(
      DateLabels.relative(DateTime(2026, 10, 1, 14, 20), now: now),
      'Today · 14:20',
    );
    expect(DateLabels.relative(DateTime(2026, 9, 30), now: now), 'Yesterday');
    expect(
      DateLabels.relative(DateTime(2026, 9, 27), now: now),
      '27 September',
    );
  });

  test('numerals and number words', () {
    expect(romanNumeral(4), 'iv');
    expect(romanNumeral(9), 'ix');
    expect(numberWord(4, capitalize: true), 'Four');
  });
}
