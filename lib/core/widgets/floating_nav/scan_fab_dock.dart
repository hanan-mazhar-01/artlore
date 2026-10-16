import 'package:flutter/widgets.dart';

import '../../extensions/context_x.dart';
import 'scan_fab.dart';

/// The scan button at the right end of the nav pill, ringed in the pill's own
/// colour and a fine line. The pill itself (tabs and this end) is drawn by the
/// nav; this is only the button, centred on the pill's right cap.
class ScanFabDock extends StatelessWidget {
  const ScanFabDock({super.key, required this.pillHeight, required this.onTap});

  /// How much wider the capsule becomes to take the button.
  static double extraWidth(double pillHeight) => pillHeight * 1.258;

  /// Gold button diameter for a pill of this height.
  static double buttonDiameter(double pillHeight) => pillHeight * .806;

  final double pillHeight;
  final VoidCallback onTap;

  /// Width of the ring around the button.
  static double ringWidth(double pillHeight) => buttonDiameter(pillHeight) + 9;

  @override
  Widget build(BuildContext context) {
    final d = buttonDiameter(pillHeight);
    final ring = ringWidth(pillHeight);
    return SizedBox(
      width: ring,
      height: pillHeight,
      child: Center(
        child: Container(
          width: ring,
          height: ring,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  (context.isDark
                          ? const Color(0xFFF5EFE5)
                          : const Color(0xFF2D2621))
                      .withValues(alpha: .45),
              width: 1.5,
            ),
          ),
          child: ScanFab(diameter: d, onTap: onTap),
        ),
      ),
    );
  }
}
