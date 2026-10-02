import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';

/// Two quiet companions to the scan card, mirrored like a diptych.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onScanPhotos,
    required this.onCollection,
    this.collectionHint,
  });

  final VoidCallback onScanPhotos;
  final VoidCallback onCollection;

  /// "7 works saved".
  final String? collectionHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: QuickAction(
              icon: ArtIcons.photos,
              label: 'Scan from Photos',
              hint: 'Your camera roll',
              radius: AppRadius.css(30, 6, 6, 30),
              onTap: onScanPhotos,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: QuickAction(
              icon: ArtIcons.gallery,
              label: 'My Collection',
              hint: collectionHint ?? 'Your galleries',
              radius: AppRadius.css(6, 30, 30, 6),
              onTap: onCollection,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact icon + text action on a hairline frame.
class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.radius,
    required this.onTap,
  });

  final ArtIconData icon;
  final String label;
  final String hint;
  final BorderRadius radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: onTap,
      semanticLabel: label,
      pressedScale: .97,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: radius,
          border: Border.all(color: p.line(.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: p.accentAlpha(.45)),
                  ),
                  child: ArtIcon(
                    icon,
                    size: 16,
                    color: p.accent,
                    strokeWidth: 1.5,
                  ),
                ),
                const Spacer(),
                ArtIcon(
                  ArtIcons.arrowRight,
                  size: 14,
                  color: p.muted,
                  strokeWidth: 1.5,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sans(14, weight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.metadata.copyWith(color: p.muted),
            ),
          ],
        ),
      ),
    );
  }
}
