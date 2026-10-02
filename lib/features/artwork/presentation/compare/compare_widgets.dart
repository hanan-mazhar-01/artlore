import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/artwork.dart';

/// Two halves of two paintings, each panning to the area under discussion.
class CompareDiptych extends StatelessWidget {
  const CompareDiptych({
    super.key,
    required this.a,
    required this.b,
    required this.focusA,
    required this.focusB,
  });

  final Artwork a;
  final Artwork b;
  final Alignment focusA;
  final Alignment focusB;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget half(Artwork art, Alignment focus) => Expanded(
      child: TweenAnimationBuilder<Alignment>(
        tween: AlignmentTween(end: focus),
        duration: AppMotion.of(context, AppMotion.slow),
        curve: Curves.ease,
        builder: (context, f, _) =>
            ArtImage(art.image, alignment: f, semanticLabel: art.semanticLabel),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            half(a, focusA),
            Container(width: 2, color: p.background),
            half(b, focusB),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 140,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [p.ground(0), p.background],
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.background,
              shape: BoxShape.circle,
              border: Border.all(color: p.accent),
            ),
            child: Text(
              '×',
              style: AppTypography.serif(24).copyWith(color: p.accent),
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontally scrolling facet chips — Color, Composition, Technique…
class FacetChips extends StatelessWidget {
  const FacetChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final on = i == selected;
          return Tappable(
            onTap: () => onSelected(i),
            semanticLabel: labels[i],
            pressedScale: .96,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              decoration: BoxDecoration(
                color: on ? p.accent : p.ground(0),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: on ? p.accent : p.line(.2)),
              ),
              child: Text(
                labels[i],
                style: AppTypography.sans(
                  12,
                  weight: FontWeight.w600,
                ).copyWith(color: on ? p.onAccent : p.ink),
              ),
            ),
          );
        },
      ),
    );
  }
}
