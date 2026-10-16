import 'dart:async';

import 'package:flutter/widgets.dart';

/// The scanned picture, held in place at the top of the screen while the
/// painting's page takes over beneath it, then let go. It lives in the root
/// overlay, so it survives the change of page; the page's own picture has time
/// to load behind it, and the two cross-fade rather than one blinking out
/// before the other is there.
abstract final class HandoverPicture {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required ImageProvider image,
    required Rect rect,
  }) {
    _remove();
    final overlay = Overlay.of(context, rootOverlay: true);
    final fade = ValueNotifier<bool>(false);
    _entry = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: ValueListenableBuilder<bool>(
          valueListenable: fade,
          builder: (context, out, _) => AnimatedOpacity(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeInOut,
            opacity: out ? 0 : 1,
            child: Stack(
              children: [
                Positioned.fromRect(
                  rect: rect,
                  child: Image(
                    image: image,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(_entry!);
    // Hold while the page fades in and loads, then cross-fade away.
    _timer = Timer(const Duration(milliseconds: 750), () {
      fade.value = true;
      _timer = Timer(const Duration(milliseconds: 480), _remove);
    });
  }

  static void _remove() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }
}
