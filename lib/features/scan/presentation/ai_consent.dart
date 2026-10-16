import '../../legal/open_legal.dart';

import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/icons/art_icon.dart';
import '../../../core/widgets/icons/art_icons.dart';
import '../../../core/widgets/tappable.dart';

/// Whether the visitor has agreed to their scanned photos being sent to
/// Google's Gemini AI. Asked once, before the first scan that needs it, and
/// withdrawable in Settings.
final aiConsentProvider = NotifierProvider<AiConsentController, bool>(
  AiConsentController.new,
);

class AiConsentController extends Notifier<bool> {
  static const _key = 'artlore.ai_consent';

  @override
  bool build() => ref.read(sharedPreferencesProvider).getBool(_key) ?? false;

  void set(bool value) {
    state = value;
    ref.read(sharedPreferencesProvider).setBool(_key, value);
  }
}

/// True if the visitor has agreed (asking first if they haven't yet).
Future<bool> ensureAiConsent(BuildContext context, WidgetRef ref) async {
  if (ref.read(aiConsentProvider)) return true;
  final agreed = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Close',
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, _, _) => const _AiConsentDialog(),
    transitionBuilder: (context, anim, _, child) {
      final curve = CurvedAnimation(
        parent: anim,
        curve: const Cubic(.2, .8, .2, 1),
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween(begin: .94, end: 1.0).animate(curve),
          child: child,
        ),
      );
    },
  );
  if (agreed == true) ref.read(aiConsentProvider.notifier).set(true);
  return agreed == true;
}

class _AiConsentDialog extends StatefulWidget {
  const _AiConsentDialog();

  @override
  State<_AiConsentDialog> createState() => _AiConsentDialogState();
}

class _AiConsentDialogState extends State<_AiConsentDialog> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    TextStyle body(double size, {Color? color}) =>
        AppTypography.sans(size, height: 1.5).copyWith(
          color: color ?? p.ink.withValues(alpha: .86),
          decoration: TextDecoration.none,
        );
    TextStyle link() => body(13.5, color: p.accent).copyWith(
      decoration: TextDecoration.underline,
      decorationColor: p.accent,
      fontWeight: FontWeight.w600,
    );
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 340,
          margin: const EdgeInsets.symmetric(horizontal: 22),
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 14),
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
                    ArtIcons.sparkle,
                    size: 24,
                    color: p.accent,
                    strokeWidth: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Before you scan',
                textAlign: TextAlign.center,
                style: AppTypography.serif(
                  24,
                  weight: FontWeight.w700,
                ).copyWith(color: p.ink, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 12),
              Text(
                'To tell you which painting this is, ArtLore sends the photo '
                'you scan to Google\'s Gemini AI service.',
                textAlign: TextAlign.center,
                style: body(14),
              ),
              const SizedBox(height: 10),
              Text(
                'It is sent only when you scan, only to identify the artwork, '
                'and nothing else from your phone goes with it. You can '
                'withdraw this any time in Settings.',
                textAlign: TextAlign.center,
                style: body(13, color: p.muted),
              ),
              const SizedBox(height: 18),
              // The agreement: a box to tick, with the two documents one tap
              // away. The button below stays off until it is ticked.
              Tappable(
                onTap: () => setState(() => _agreed = !_agreed),
                semanticLabel: 'I agree to the Privacy Policy and Terms of Use',
                pressedScale: .99,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: _agreed ? p.accent : const Color(0x00000000),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: _agreed ? p.accent : p.line(.5),
                          width: 1.6,
                        ),
                      ),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 160),
                        opacity: _agreed ? 1 : 0,
                        child: Center(
                          child: ArtIcon(
                            ArtIcons.check,
                            size: 15,
                            color: p.background,
                            strokeWidth: 2.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: body(13.5),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () => openLegal(context, privacy: true),
                                child: Text('Privacy Policy', style: link()),
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () => openLegal(context, privacy: false),
                                child: Text('Terms of Use', style: link()),
                              ),
                            ),
                            const TextSpan(
                              text:
                                  ', and to my scanned photos being sent to '
                                  'Google Gemini to identify them.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _agreed ? 1 : .38,
                child: Tappable(
                  onTap: _agreed ? () => Navigator.of(context).pop(true) : null,
                  semanticLabel: 'Continue',
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.inverse,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Continue',
                      style: AppTypography.sans(14.5, weight: FontWeight.w700)
                          .copyWith(
                            color: p.onInverse,
                            decoration: TextDecoration.none,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Tappable(
                onTap: () => Navigator.of(context).pop(false),
                semanticLabel: 'Not now',
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  child: Text(
                    'Not now',
                    style: AppTypography.sans(
                      14,
                      weight: FontWeight.w600,
                    ).copyWith(color: p.muted, decoration: TextDecoration.none),
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
