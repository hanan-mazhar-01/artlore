import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_image.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/editorial_text.dart';
import '../../../core/widgets/icons/art_icon.dart';
import '../../../core/widgets/icons/art_icons.dart';
import '../../../core/widgets/round_buttons.dart';
import '../domain/art_journey.dart';
import 'journey_providers.dart';
import 'widgets/taste_trait_row.dart';

const _painterShapes = [ArtShape.arch, ArtShape.soft, ArtShape.leaf];

const _previewTraits = [
  ('Atmospheric', 'Light, ambience & brushwork depth'),
  ('Emotional Depth', 'Vivid contrasts & expressive color palettes'),
  ('Composition', 'Architectural balance, perspective & form'),
  ('Curiosity', 'Historical periods & art movements explored'),
];

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
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.only(top: context.topInset, bottom: 60),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight - context.topInset - 60,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -30,
                top: -20,
                width: 280,
                height: 280,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          p.accent.withValues(alpha: .10),
                          p.accent.withValues(alpha: 0),
                        ],
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
                            40,
                            weight: FontWeight.w700,
                            height: 1.1,
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
                  if (journey.traits.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: p.line(.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your aesthetic fingerprint is waiting.',
                              style: AppTypography.sans(
                                16,
                                weight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Scan or save artworks to discover your visual taste, '
                              'dominant artistic movements, and unique creative traits.',
                              style: AppTypography.bodySmall.copyWith(
                                color: p.muted,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            PillButton(
                              label: 'Scan an artwork',
                              style: PillStyle.outline,
                              trailingArrow: true,
                              onTap: () => context.push(AppRoutes.scan),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GoldLabel(
                            'Taste dimensions you will unlock',
                            tracking: .24,
                            color: p.muted,
                          ),
                          const SizedBox(height: 14),
                          for (final (label, desc) in _previewTraits)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: p.line(.08))),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: AppTypography.sans(
                                          15,
                                          weight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        desc,
                                        style: AppTypography.caption.copyWith(
                                          color: p.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '—',
                                    style: AppTypography.sans(16).copyWith(
                                      color: p.muted.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Journey stats bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: p.line(.08)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatBadge(
                              value: journey.stats.artworks,
                              label: 'Artworks',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: p.line(.1),
                            ),
                            _StatBadge(
                              value: journey.stats.artists,
                              label: 'Artists',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: p.line(.1),
                            ),
                            _StatBadge(
                              value: journey.stats.movements,
                              label: 'Movements',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
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
                        style: AppTypography.sans(
                          16,
                          height: 1.6,
                        ).copyWith(color: p.ink.withValues(alpha: .88)),
                      ),
                    ),
                    if (journey.painters.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GoldLabel(
                              'Artworks shaping your taste',
                              tracking: .24,
                              color: p.muted,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0;
                                    i < journey.painters.length;
                                    i++) ...[
                                  if (i > 0) const SizedBox(width: 12),
                                  Expanded(
                                    child: _Painter(
                                      painter: journey.painters[i],
                                      shape: _painterShapes[
                                          i % _painterShapes.length],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (journey.habitNote.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: p.line(.08)),
                          ),
                          child: Row(
                            children: [
                              ArtIcon(ArtIcons.brush, size: 18, color: p.accent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  journey.habitNote,
                                  style: AppTypography.caption.copyWith(
                                    color: p.muted,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: AppTypography.sans(20, weight: FontWeight.w500).copyWith(
            color: p.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.sans(11, weight: FontWeight.w500).copyWith(
            color: p.muted,
          ),
        ),
      ],
    );
  }
}

class _Painter extends StatelessWidget {
  const _Painter({required this.painter, required this.shape});

  final ReturningPainter painter;
  final ArtShape shape;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 0.85,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: p.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ArtImage(
              painter.artwork.image,
              radius: shape.radius,
              semanticLabel: painter.artwork.semanticLabel,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          painter.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.sans(13, weight: FontWeight.w500).copyWith(
            color: p.ink,
          ),
        ),
        Text(
          painter.artwork.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(color: p.muted),
        ),
      ],
    );
  }
}
