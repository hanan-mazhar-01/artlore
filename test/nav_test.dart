import 'package:artlore/core/widgets/floating_nav/art_nav_item.dart';
import 'package:artlore/core/widgets/floating_nav/nav_spotlight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpotlightMotion', () {
    test('glides from the old item to the new one', () {
      final m = SpotlightMotion.at(0, 4).retarget(3, 0);
      expect(m.position(0), 0);
      expect(m.position(.5), inInclusiveRange(1.3, 1.7));
      expect(m.position(1), 3);
      expect(m.weight(0, 1), 0);
      expect(m.weight(3, 1), 1);
    });

    test('bars cross-fade in place while the beam dims mid-travel', () {
      final m = SpotlightMotion.at(1, 4).retarget(2, 0);
      expect(m.weight(1, .5), closeTo(.5, .001));
      expect(m.weight(2, .5), closeTo(.5, .001));
      expect(m.beam(.5), lessThan(1));
      expect(m.beam(1), closeTo(1, .001));
    });

    test('an interrupted move continues from where the light is', () {
      final first = SpotlightMotion.at(0, 4).retarget(3, 0);
      final mid = first.position(.4);
      final second = first.retarget(1, .4);
      expect(second.position(0), closeTo(mid, 1e-9));
      expect(second.weight(0, 0), closeTo(first.weight(0, .4), 1e-9));
    });
  });

  test('metrics keep the reference proportions and fit small phones', () {
    final iphone = FloatingNavMetrics.forScreen(390, 4);
    expect(iphone.width / iphone.height, closeTo(5.2, .05));
    expect(iphone.slot, greaterThanOrEqualTo(44)); // touch target
    final small = FloatingNavMetrics.forScreen(320, 4);
    expect(small.width, lessThanOrEqualTo(320 - 48));
    expect(small.slot, greaterThanOrEqualTo(44));
  });
}
