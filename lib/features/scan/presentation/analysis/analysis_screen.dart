import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/ambient_motion.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/art_scaffold.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/design_stage.dart';
import '../../../../core/widgets/reveal_image.dart';
import '../../../artwork/data/mock_catalog.dart';
import 'analysis_controller.dart';
import 'analysis_widgets.dart';

/// The identifying state: the capture surfaces from darkness while ArtLore
/// "reads" it, then hands over to the result.
class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key, this.photoId});

  /// A library photo being read instead of a camera capture.
  final String? photoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = analysisControllerProvider(photoId);
    ref.listen(provider.select((s) => s.result), (_, r) {
      if (r == null) return;
      Haptics.play(HapticKind.success);
      context.pushReplacement(AppRoutes.artwork(r.artworkId));
    });
    final p = context.palette;
    final state = ref.watch(provider);
    // The frame being read: the picked photo, or the scanner's painting.
    final capture =
        (mockCatalog[photoId] ?? mockCatalog[ArtworkIds.starryNight]!).image;
    return ArtScaffold(
      swipeBack: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: Opacity(
                opacity: .16,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: ArtImage(capture, decodeScale: .25),
                ),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: context.topInset + 50),
              Expanded(
                child: DesignStage(
                  height: 400,
                  children: [
                    Positioned(
                      left: 55,
                      top: 12,
                      width: 280,
                      height: 380,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.css(140, 140, 4, 4),
                          boxShadow: AppShadows.artwork(p),
                        ),
                        child: ClipRRect(
                          borderRadius: AppRadius.css(140, 140, 4, 4),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              RevealImage(
                                capture,
                                duration: const Duration(seconds: 5),
                                curve: const Cubic(.3, .6, .2, 1),
                              ),
                              const SweepLine(
                                period: Duration(milliseconds: 2400),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Positioned.fill(child: AnalysisMotes()),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  32,
                  34,
                  32,
                  math.max(28.0, context.bottomInset + 12),
                ),
                child: state.failed
                    ? _Failed(onRetry: () => context.backOr())
                    : AnalysisStepList(step: state.step),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This one keeps its secrets.',
          style: AppTypography.serif(26, italic: true),
        ),
        const SizedBox(height: 18),
        PillButton(label: 'Try again', onTap: onRetry, trailingArrow: true),
      ],
    );
  }
}
