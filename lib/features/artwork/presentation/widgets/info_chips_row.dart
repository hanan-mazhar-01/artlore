import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../domain/artwork.dart';

/// Three small facts the visitor would otherwise have to read in one long
/// line — where it hangs, how big it is, what it's made of.
class InfoChipsRow extends StatelessWidget {
  const InfoChipsRow({super.key, required this.artwork});

  final Artwork artwork;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _InfoChip(
              icon: ArtIcons.gallery,
              label: 'On display',
              value: artwork.museum,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoChip(
              icon: ArtIcons.expand,
              label: 'Dimensions',
              value: artwork.dimensions,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoChip(
              icon: ArtIcons.brush,
              label: 'Medium',
              value: artwork.medium,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final ArtIconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ArtIcon(icon, size: 16, color: p.accent, strokeWidth: 1.6),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(12, weight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.metadata.copyWith(color: p.muted),
          ),
        ],
      ),
    );
  }
}
