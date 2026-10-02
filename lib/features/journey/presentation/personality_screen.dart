import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_image.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/editorial_text.dart';
import '../../../core/widgets/round_buttons.dart';
import '../domain/art_journey.dart';
import 'journey_providers.dart';
import 'widgets/taste_trait_row.dart';

const _painterShapes = [ArtShape.arch, ArtShape.soft, ArtShape.leaf];

/// "Your art taste — The Night Romantic".
class PersonalityScreen extends ConsumerWidget {
  const PersonalityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journey = ref.watch(artJourneyProvider);
    return ArtScaffold(
      body: AsyncView(
        value: journey,
        onRetry: () => ref.invalidate(artJourneyProvider),
        data: (j) => _PersonalityBody(journey: j),
      ),
    );
  }
}

class _PersonalityBody extends StatelessWidget {
  const _PersonalityBody({required this.journey});

  final ArtJourney journey;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final backdrop = journey.painters.length > 1
        ? journey.painters[1].artwork
        : journey.painters.first.artwork;
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: context.topInset, bottom: 60),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -80,
            top: -22,
            width: 340,
            height: 460,
            child: IgnorePointer(
              child: RepaintBoundary(
                child: Opacity(
                  opacity: .16,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: ArtImage(backdrop.image, decodeScale: .3),
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlineIconButton(onTap: () => context.backOr()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GoldLabel(
                      'Your art taste',
                      size: 11,
                      tracking: .32,
                      weight: FontWeight.w600,
                    ),
                    const SizedBox(height: 14),
                    EditorialHeading(
                      lead: journey.personaLead,
                      emphasis: journey.personaEmphasis,
                      style: AppTypography.serif(
                        46,
                        weight: FontWeight.w500,
                        height: .98,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      journey.basis,
                      style: AppTypography.caption.copyWith(color: p.muted),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                child: Column(
                  children: [
                    for (var i = 0; i < journey.traits.length; i++)
                      TasteTraitRow(trait: journey.traits[i], rank: i),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                padding: const EdgeInsets.only(top: 24),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: p.line(.1))),
                ),
                child: Text(
                  journey.summary,
                  style: AppTypography.serif(24, italic: true, height: 1.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GoldLabel(
                      'Painters you return to',
                      tracking: .24,
                      color: p.muted,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        for (var i = 0; i < journey.painters.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(
                            child: _Painter(
                              painter: journey.painters[i],
                              shape: _painterShapes[i % _painterShapes.length],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Painter extends StatelessWidget {
  const _Painter({required this.painter, required this.shape});

  final ReturningPainter painter;
  final ArtShape shape;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: ArtImage(
            painter.artwork.image,
            radius: shape.radius,
            semanticLabel: painter.artwork.semanticLabel,
          ),
        ),
        const SizedBox(height: 8),
        Text(painter.name, style: AppTypography.caption),
      ],
    );
  }
}
