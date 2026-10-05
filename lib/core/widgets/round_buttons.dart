import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../extensions/context_x.dart';
import 'icons/art_icon.dart';
import 'icons/art_icons.dart';
import 'tappable.dart';

/// 42pt frosted circle floating over artwork (back, save, reset…).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.size = 42,
    this.iconSize = 18,
    this.color,
    this.filled = false,
    this.bordered = true,
  });

  final ArtIconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final double size;
  final double iconSize;
  final Color? color;
  final bool filled;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      pressedScale: .94,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.glass,
              shape: BoxShape.circle,
              border: bordered ? Border.all(color: p.line(.14)) : null,
            ),
            child: ArtIcon(
              icon,
              size: iconSize,
              color: color ?? p.ink,
              filled: filled,
            ),
          ),
        ),
      ),
    );
  }
}

/// 42pt hairline circle on plain ground — the back button on list pages.
class OutlineIconButton extends StatelessWidget {
  const OutlineIconButton({
    super.key,
    required this.onTap,
    this.icon = ArtIcons.chevronLeft,
    this.semanticLabel = 'Back',
  });

  final ArtIconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      pressedScale: .94,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: p.line(.14)),
        ),
        child: ArtIcon(icon, size: 18, color: p.ink),
      ),
    );
  }
}

/// Initials or Photo in a gold-ringed disc (header avatar, profile).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = 36,
    this.style,
    this.ringOpacity = .5,
    this.elevated = false,
  });

  final String initials;
  final String? imageUrl;
  final double size;
  final TextStyle? style;
  final double ringOpacity;

  /// A soft drop shadow, for when the disc is itself the button (as in the
  /// Home header) rather than a decorative portrait (as in Profile).
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.surface,
        border: Border.all(color: p.accentAlpha(ringOpacity)),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: p.shadow.withValues(alpha: p.shadow.a * .55),
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: Text(initials, style: style?.copyWith(color: p.accent)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('InitialsAvatar image load error ($imageUrl): $error');
                  return Center(
                    child: Text(initials, style: style?.copyWith(color: p.accent)),
                  );
                },
              )
            : Center(
                child: Text(initials, style: style?.copyWith(color: p.accent)),
              ),
      ),
    );
  }
}
