import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/round_buttons.dart';
import 'history_controller.dart';
import 'widgets/history_timeline_item.dart';

/// "Your history" — every painting stood before, on a quiet timeline.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final history = ref.watch(historyProvider);
    return ArtScaffold(
      body: AsyncView(
        value: history,
        onRetry: () => ref.invalidate(historyProvider),
        data: (entries) => CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, context.topInset, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlineIconButton(onTap: () => context.backOr()),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Your history',
                        style: AppTypography.pageTitle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Every painting you\'ve stood before, and what you '
                      'found.',
                      style: AppTypography.sans(13).copyWith(color: p.muted),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 60),
              sliver: SliverList.builder(
                itemCount: entries.length,
                itemBuilder: (context, i) => HistoryTimelineItem(
                  entry: entries[i],
                  isFirst: i == 0,
                  shapeIndex: i,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
