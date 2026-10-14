import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/presentation/artwork_providers.dart';
import '../../../history/domain/history_entry.dart';
import '../home_providers.dart';
import 'home_style.dart';

/// "Recent Scans": a title with "See all", then a rail of tall cards — or an
/// inviting empty state when nothing has been scanned yet.
class RecentScansSection extends ConsumerWidget {
  const RecentScansSection({super.key, required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = HomeStyle.of(context);
    final scans = ref.watch(recentScansProvider);
    final hasScans = scans != null && scans.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'Recent Scans',
                  style: AppTypography.serif(
                    26,
                    weight: FontWeight.w700,
                  ).copyWith(color: s.ink),
                ),
              ),
              if (hasScans)
                Tappable(
                  onTap: () => context.push(AppRoutes.history),
                  semanticLabel: 'See all scans',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See all',
                          style: AppTypography.sans(
                            13,
                            weight: FontWeight.w600,
                          ).copyWith(color: s.ink),
                        ),
                        const SizedBox(width: 4),
                        ArtIcon(
                          ArtIcons.chevronRight,
                          size: 14,
                          color: s.ink,
                          strokeWidth: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (scans == null)
          const SizedBox(height: 212)
        else if (scans.isEmpty)
          _EmptyScans(onScan: onScan, style: s)
        else
          SizedBox(
            height: 212 + 6,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
              itemCount: scans.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => FadeSlideIn(
                axis: Axis.horizontal,
                offset: 24,
                delay: Duration(milliseconds: 70 * i.clamp(0, 5)),
                child: _ScanCard(entry: scans[i], style: s),
              ),
            ),
          ),
      ],
    );
  }
}

class _ScanCard extends ConsumerWidget {
  const _ScanCard({required this.entry, required this.style});

  final HistoryEntry entry;
  final HomeStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = style;
    final artwork = ref.watch(artworkProvider(entry.artworkId)).value;
    if (artwork == null) return const SizedBox(width: 156);
    return Tappable(
      onTap: () => context.openArtwork(artwork.id),
      semanticLabel:
          '${artwork.semanticLabel}, scanned ${DateLabels.ago(entry.at)}',
      pressedScale: .97,
      child: Container(
        width: 156,
        height: 212,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: s.tile,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: s.shadow(.5),
              offset: const Offset(0, 12),
              blurRadius: 22,
              spreadRadius: -16,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ArtImage(artwork.image, alignment: artwork.heroFocus),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x0026231F), Color(0xE026231F)],
                  stops: [.45, 1],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xE6F7F2EC),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  DateLabels.ago(entry.at).toUpperCase(),
                  style: AppTypography.sans(
                    9.5,
                    weight: FontWeight.w700,
                    tracking: .12,
                  ).copyWith(color: const Color(0xFF26231F)),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.serif(
                      18,
                      weight: FontWeight.w700,
                      height: 1.12,
                    ).copyWith(color: s.onImage),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artwork.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sans(
                      11.5,
                      weight: FontWeight.w500,
                    ).copyWith(color: s.goldLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyScans extends StatelessWidget {
  const _EmptyScans({required this.onScan, required this.style});

  final VoidCallback onScan;
  final HomeStyle style;

  @override
  Widget build(BuildContext context) {
    final s = style;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: CustomPaint(
        painter: _DashedRRect(color: s.line, radius: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
          decoration: BoxDecoration(
            color: s.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // A little empty picture frame.
              Container(
                width: 64,
                height: 80,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: s.ground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: s.line, width: 2),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: s.ground,
                    border: Border.all(color: s.line),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your gallery is waiting',
                textAlign: TextAlign.center,
                style: AppTypography.serif(
                  22,
                  weight: FontWeight.w700,
                ).copyWith(color: s.ink),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(
                  'Paintings you scan will appear here with their stories.',
                  textAlign: TextAlign.center,
                  style: AppTypography.sans(
                    13,
                    weight: FontWeight.w500,
                    height: 1.45,
                  ).copyWith(color: s.muted),
                ),
              ),
              const SizedBox(height: 14),
              Tappable(
                onTap: onScan,
                semanticLabel: 'Scan your first painting',
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s.deep,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    'Scan your first painting',
                    style: AppTypography.sans(
                      13.5,
                      weight: FontWeight.w700,
                    ).copyWith(color: s.onDeep),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A 1px dashed rounded rectangle.
class _DashedRRect extends CustomPainter {
  const _DashedRRect({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(.5),
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRect old) =>
      old.color != color || old.radius != radius;
}
