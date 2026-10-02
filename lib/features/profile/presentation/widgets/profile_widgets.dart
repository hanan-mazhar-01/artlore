import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../journey/domain/art_journey.dart';
import '../../domain/user_profile.dart';

/// Avatar, name and "Visitor since".
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        InitialsAvatar(
          initials: profile.initials,
          size: 72,
          ringOpacity: 1,
          style: AppTypography.serif(28),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: AppTypography.serif(
                  30,
                  weight: FontWeight.w500,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Visitor since ${profile.memberSince}',
                style: AppTypography.caption.copyWith(color: p.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Your art world" — three big serif numbers between hairlines.
class ArtWorldStats extends StatelessWidget {
  const ArtWorldStats({
    super.key,
    required this.stats,
    this.title = 'Your art world',
    this.labels = const ('artworks', 'artists', 'movements'),
    this.footer,
  });

  final JourneyStats stats;
  final String title;

  /// Captions under the artworks / artists / movements numbers.
  final (String, String, String) labels;

  /// Optional line under the numbers, e.g. "View your journey →".
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rule = BorderSide(color: p.line(.12));
    Widget stat(int value, String label, {bool divider = true}) => Expanded(
      child: Container(
        padding: EdgeInsets.only(left: divider ? 16 : 0),
        decoration: BoxDecoration(
          border: divider ? Border(left: BorderSide(color: p.line(.1))) : null,
        ),
        child: Semantics(
          label: '$value $label',
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value', style: AppTypography.serif(46, height: 1)),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(color: p.muted),
              ),
            ],
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        border: Border(top: rule, bottom: rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GoldLabel(title),
          const SizedBox(height: 18),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                stat(stats.artworks, labels.$1, divider: false),
                stat(stats.artists, labels.$2),
                stat(stats.movements, labels.$3),
              ],
            ),
          ),
          if (footer != null) ...[const SizedBox(height: 20), footer!],
        ],
      ),
    );
  }
}

/// Serif menu row with a quiet chevron.
class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Gold title — used for Premium.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.line(.08))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.serif(23)
                        .copyWith(color: highlight ? p.accent : p.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.metadata.copyWith(color: p.muted),
                  ),
                ],
              ),
            ),
            ArtIcon(
              ArtIcons.chevronRight,
              size: 15,
              color: p.muted,
              strokeWidth: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}
