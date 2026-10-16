import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/icons/art_icons.dart';
import '../../../core/widgets/round_buttons.dart';
import '../legal_text.dart';

/// The Privacy Policy or the Terms of Use, read inside the app.
class LegalScreen extends StatelessWidget {
  const LegalScreen.privacy({super.key}) : _privacy = true;
  const LegalScreen.terms({super.key}) : _privacy = false;

  final bool _privacy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final title = _privacy ? 'Privacy Policy' : 'Terms of Use';
    final intro = _privacy ? LegalText.privacyIntro : LegalText.termsIntro;
    final sections = _privacy ? LegalText.privacy : LegalText.terms;
    return ArtScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          context.topInset + 12,
          24,
          context.bottomInset + 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassIconButton(
              icon: ArtIcons.chevronLeft,
              onTap: () => context.backOr(AppRoutes.settings),
              semanticLabel: 'Back',
            ),
            const SizedBox(height: 22),
            Semantics(
              header: true,
              child: Text(
                title,
                style: AppTypography.serif(
                  38,
                  weight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Effective ${LegalInfo.effective}',
              style: AppTypography.caption.copyWith(color: p.muted),
            ),
            const SizedBox(height: 18),
            Text(intro, style: AppTypography.body.copyWith(color: p.ink)),
            for (final s in sections) ...[
              const SizedBox(height: 26),
              Text(
                s.heading,
                style: AppTypography.sans(
                  17,
                  weight: FontWeight.w700,
                ).copyWith(color: p.ink),
              ),
              const SizedBox(height: 8),
              for (final line in s.body)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    line,
                    style: AppTypography.bodySmall.copyWith(
                      color: p.ink.withValues(alpha: .86),
                    ),
                  ),
                ),
            ],
            if (!_privacy) ...[
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse(
                    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                  ),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(
                  "Apple's Standard End User License Agreement",
                  style: AppTypography.bodySmall.copyWith(
                    color: p.accent,
                    decoration: TextDecoration.underline,
                    decorationColor: p.accent,
                  ),
                ),
              ),
            ],
            if (LegalInfo.supportEmail.isNotEmpty) ...[
              const SizedBox(height: 26),
              Text(
                'Questions? ${LegalInfo.supportEmail}',
                style: AppTypography.bodySmall.copyWith(color: p.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
