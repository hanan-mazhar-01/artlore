import 'dart:async';

import 'package:flutter/widgets.dart';

import '../extensions/context_x.dart';
import '../theme/app_typography.dart';
import 'fade_slide_in.dart';
import 'tappable.dart';

/// Ivory pill confirmation — "Hung in Night Skies · View".
abstract final class ArtToast {
  static OverlayEntry? _current;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    dismiss();
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (ctx) => _ToastView(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction == null
            ? null
            : () {
                dismiss();
                onAction();
              },
      ),
    );
    _current = entry;
    overlay.insert(entry);
    _timer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = AppTypography.sans(13, weight: FontWeight.w600);
    return Positioned(
      left: 24,
      right: 24,
      bottom: 40 + context.bottomInset * .4,
      child: FadeSlideIn(
        duration: const Duration(milliseconds: 500),
        child: Semantics(
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: p.inverse,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: style.copyWith(color: p.onInverse),
                  ),
                ),
                if (actionLabel != null)
                  Tappable(
                    onTap: onAction,
                    semanticLabel: actionLabel,
                    child: Text(
                      actionLabel!,
                      style: style.copyWith(color: p.inverseLink),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
