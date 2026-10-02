import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/context_x.dart';
import '../theme/app_typography.dart';
import 'buttons.dart';

/// Renders an [AsyncValue] with the gallery's quiet loading and error
/// states — never a spinner on a white page.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncData(:final value) => data(value),
      AsyncError() => _ErrorState(onRetry: onRetry),
      _ => const SizedBox.expand(),
    };
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The gallery is quiet.',
              textAlign: TextAlign.center,
              style: AppTypography.serif(28, italic: true),
            ),
            const SizedBox(height: 10),
            Text(
              'We couldn\'t open this room just now.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: p.muted),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              TextAction(label: 'Try again', onTap: onRetry, color: p.accent),
            ],
          ],
        ),
      ),
    );
  }
}
