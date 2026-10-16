import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../journey/domain/art_journey.dart';
import '../../domain/user_profile.dart';

/// Avatar, name, "Visitor since", and subscription / scans status.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.onEdit,
    this.subscriptionLabel,
    this.isPremium = false,
  });

  final UserProfile profile;
  final VoidCallback? onEdit;
  final String? subscriptionLabel;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        InitialsAvatar(
          initials: profile.initials,
          imageUrl: profile.photoUrl,
          size: 72,
          ringOpacity: 1,
          style: AppTypography.serif(28),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    // A long name shrinks to fit rather than being cut off.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        profile.name,
                        maxLines: 1,
                        style: AppTypography.serif(
                          40,
                          weight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  if (onEdit != null) ...[
                    const SizedBox(width: 8),
                    Tappable(
                      onTap: onEdit,
                      semanticLabel: 'Edit Name',
                      child: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: p.muted,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Visitor since ${profile.memberSince}',
                style: AppTypography.caption.copyWith(color: p.muted),
              ),
              if (subscriptionLabel != null) ...[
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: isPremium
                        ? p.accent.withValues(alpha: 0.12)
                        : p.surfaceAlt,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isPremium
                          ? p.accent.withValues(alpha: 0.28)
                          : p.line(0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPremium ? p.accent : p.muted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        subscriptionLabel!,
                        style: AppTypography.sans(11, weight: FontWeight.w600)
                            .copyWith(
                              color: isPremium ? p.accent : p.ink,
                              letterSpacing: 0.2,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
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
    this.labels = const ('artworks', 'artists', 'collections'),
    this.footer,
  });

  final JourneyStats stats;
  final String title;

  /// Captions under the artworks / artists / collections numbers.
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
              Text(
                '$value',
                style:
                    AppTypography.serif(
                      46,
                      weight: FontWeight.w700,
                      height: 1,
                    ).copyWith(
                      fontFeatures: const [
                        FontFeature.liningFigures(),
                        FontFeature.tabularFigures(),
                      ],
                    ),
              ),
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
                stat(stats.collections, labels.$3),
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
    this.danger = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Gold title — used for Premium.
  final bool highlight;

  /// Crimson/danger title — used for Delete Account.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final titleColor = danger ? p.danger : (highlight ? p.accent : p.ink);
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
                    style: AppTypography.sans(
                      17,
                      weight: FontWeight.w600,
                    ).copyWith(color: titleColor),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTypography.sans(13, height: 1.35).copyWith(
                      color: danger
                          ? p.danger.withValues(alpha: 0.75)
                          : p.muted,
                    ),
                  ),
                ],
              ),
            ),
            ArtIcon(
              ArtIcons.chevronRight,
              size: 15,
              color: danger ? p.danger : p.muted,
              strokeWidth: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}
