import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/extensions/context_x.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/icons/art_icon.dart';
import '../../core/widgets/icons/art_icons.dart';
import '../../core/widgets/tappable.dart';

/// How many paintings the wall holds.
const maxWallWorks = 3;

/// What happened when a painting was offered to the wall.
enum HangResult { hung, alreadyThere, full }

/// The paintings hanging on the visitor's wall — chosen by them, at most
/// [maxWallWorks], newest hung first. Separate from the collection: saving a
/// work does not hang it, and taking one down does not unsave it.
final wallProvider = NotifierProvider<WallController, List<String>>(
  WallController.new,
);

class WallController extends Notifier<List<String>> {
  static const _baseKey = 'artlore.wall';

  /// The wall belongs to the signed-in visitor, so another account on the
  /// same phone, or a new one made after deleting an account, starts bare.
  String get _key {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    return uid == null || uid.isEmpty ? '$_baseKey.guest' : '$_baseKey.$uid';
  }

  @override
  List<String> build() {
    ref.watch(authStateProvider);
    final saved = ref.read(sharedPreferencesProvider).getStringList(_key);
    return List.unmodifiable((saved ?? const <String>[]).take(maxWallWorks));
  }

  bool contains(String artworkId) => state.contains(artworkId);

  /// Hangs [artworkId] — unless it is already up, or the wall is full.
  HangResult hang(String artworkId) {
    if (state.contains(artworkId)) return HangResult.alreadyThere;
    if (state.length >= maxWallWorks) return HangResult.full;
    _set([artworkId, ...state]);
    return HangResult.hung;
  }

  void remove(String artworkId) => _set([
    for (final id in state)
      if (id != artworkId) id,
  ]);

  void _set(List<String> ids) {
    state = List.unmodifiable(ids);
    ref.read(sharedPreferencesProvider).setStringList(_key, ids);
  }
}

/// Whether one painting is on the wall — widgets watch just this bit.
final onWallProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(wallProvider.select((w) => w.contains(id))),
);

/// The popup shown when a fourth painting is offered to a full wall.
Future<void> showWallFullDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, _, _) => const _WallFullDialog(),
    transitionBuilder: (context, anim, _, child) {
      final curve = CurvedAnimation(
        parent: anim,
        curve: const Cubic(.2, .8, .2, 1),
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween(begin: .92, end: 1.0).animate(curve),
          child: child,
        ),
      );
    },
  );
}

class _WallFullDialog extends StatelessWidget {
  const _WallFullDialog();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 318,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: p.line(.14)),
            boxShadow: [
              BoxShadow(
                color: p.shadow,
                offset: const Offset(0, 24),
                blurRadius: 48,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.accentAlpha(.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: p.accentAlpha(.35)),
                  ),
                  child: ArtIcon(
                    ArtIcons.wall,
                    size: 26,
                    color: p.accent,
                    strokeWidth: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your wall is full',
                textAlign: TextAlign.center,
                style: AppTypography.serif(
                  24,
                  weight: FontWeight.w700,
                ).copyWith(color: p.ink, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 10),
              Text(
                "You can't hang a 4th painting on the wall. Delete any of the "
                'previous ones, then you can hang a new one.',
                textAlign: TextAlign.center,
                style: AppTypography.sans(14, height: 1.5).copyWith(
                  color: p.ink.withValues(alpha: .86),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'To take one down, press and hold it on the Home screen and '
                'drag it off the wall.',
                textAlign: TextAlign.center,
                style: AppTypography.sans(
                  12.5,
                  height: 1.5,
                ).copyWith(color: p.muted, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 20),
              Tappable(
                onTap: () => Navigator.of(context).pop(),
                semanticLabel: 'Got it',
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.inverse,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Got it',
                    style: AppTypography.sans(14.5, weight: FontWeight.w700)
                        .copyWith(
                          color: p.onInverse,
                          decoration: TextDecoration.none,
                        ),
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

/// How the wall works, in two short steps — opened by the wall's guide icon.
Future<void> showWallGuide(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, _, _) => const _WallGuide(),
    transitionBuilder: (context, anim, _, child) {
      final curve = CurvedAnimation(
        parent: anim,
        curve: const Cubic(.2, .8, .2, 1),
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween(begin: .92, end: 1.0).animate(curve),
          child: child,
        ),
      );
    },
  );
}

class _WallGuide extends StatelessWidget {
  const _WallGuide();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget step(ArtIconData icon, String title, String body) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.accentAlpha(.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.accentAlpha(.35)),
          ),
          child: ArtIcon(icon, size: 21, color: p.accent, strokeWidth: 1.7),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.sans(
                  14.5,
                  weight: FontWeight.w700,
                ).copyWith(color: p.ink, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: AppTypography.sans(
                  13,
                  height: 1.45,
                ).copyWith(color: p.muted, decoration: TextDecoration.none),
              ),
            ],
          ),
        ),
      ],
    );
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 330,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: p.line(.14)),
            boxShadow: [
              BoxShadow(
                color: p.shadow,
                offset: const Offset(0, 24),
                blurRadius: 48,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your wall',
                style: AppTypography.serif(
                  24,
                  weight: FontWeight.w700,
                ).copyWith(color: p.ink, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 4),
              Text(
                'Hang up to three paintings.',
                style: AppTypography.sans(13)
                    .copyWith(color: p.muted, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 20),
              step(
                ArtIcons.wall,
                'To hang a painting',
                'Open any painting and tap the picture-on-a-nail button at the '
                    'top right, next to the bookmark.',
              ),
              const SizedBox(height: 16),
              step(
                ArtIcons.trash,
                'To take one down',
                'Press and hold a frame on the wall, drag it off the wall and '
                    'let go. Or open the painting and tap the same button again.',
              ),
              const SizedBox(height: 22),
              Tappable(
                onTap: () => Navigator.of(context).pop(),
                semanticLabel: 'Got it',
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.inverse,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Got it',
                    style: AppTypography.sans(14.5, weight: FontWeight.w700)
                        .copyWith(
                          color: p.onInverse,
                          decoration: TextDecoration.none,
                        ),
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
