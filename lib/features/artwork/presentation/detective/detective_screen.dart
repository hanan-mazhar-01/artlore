import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_scaffold.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../domain/detective_case.dart';
import '../artwork_providers.dart';
import 'detective_canvas.dart';
import 'detective_controller.dart';
import 'detective_footer.dart';

/// Art Detective — find the detail most visitors miss.
class DetectiveScreen extends ConsumerWidget {
  const DetectiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(detectiveCasesProvider);
    return ArtScaffold(
      body: AsyncView(
        value: cases,
        onRetry: () => ref.invalidate(detectiveCasesProvider),
        data: (list) => list.isEmpty
            ? const SizedBox.expand()
            : _DetectiveBody(cases: list),
      ),
    );
  }
}

class _DetectiveBody extends ConsumerWidget {
  const _DetectiveBody({required this.cases});

  final List<DetectiveCase> cases;

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(detectiveControllerProvider);
    final ctl = ref.read(detectiveControllerProvider.notifier);
    final c = cases[state.caseIndex % cases.length];
    final artwork = ref.watch(artworkProvider(c.artworkId)).value;
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: context.topInset, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlineIconButton(onTap: () => context.backOr()),
                Text(
                  'Case ${_two(c.number)} of ${_two(c.total)}',
                  style: AppTypography.metadata.copyWith(color: p.muted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GoldLabel(
                  'Art detective',
                  size: 11,
                  tracking: .34,
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 10),
                EditorialHeading(
                  lead: 'Can you find the',
                  emphasis: 'hidden detail?',
                  style: AppTypography.serif(
                    38,
                    weight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: p.accent)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GoldLabel('The challenge', tracking: .22, color: p.muted),
                const SizedBox(height: 6),
                Text(c.challenge, style: AppTypography.serif(22, height: 1.2)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (artwork != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DetectiveCanvas(
                key: ValueKey(c.artworkId),
                artwork: artwork,
                detectiveCase: c,
                state: state,
                onTap: (tap, box) => ctl.tap(c, tap, box, artwork.image.aspect),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: DetectiveFooter(
              detectiveCase: c,
              state: state,
              onHint: ctl.showHint,
              onNext: () => ctl.nextCase(cases.length),
              nextLabel:
                  '${_two(cases[(state.caseIndex + 1) % cases.length].number)}'
                  ' of ${_two(c.total)}',
            ),
          ),
        ],
      ),
    );
  }
}
