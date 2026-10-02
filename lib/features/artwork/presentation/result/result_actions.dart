import 'package:flutter/widgets.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/number_words.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/artwork_content.dart';

/// The numbered ways into a work — Look Closer, Listen, Detective, Deep Dive.
/// Rows appear only when there is content behind them.
class ResultActions extends StatelessWidget {
  const ResultActions({
    super.key,
    required this.artworkId,
    required this.content,
  });

  final String artworkId;
  final ArtworkContent content;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final details = content.details.length;
    final rows = <(String, String, String)>[
      if (details > 0)
        (
          'Look Closer',
          '${numberWord(details, capitalize: true)} details worth a second look',
          AppRoutes.lookCloser(artworkId),
        ),
      if (content.narration != null)
        (
          'Listen',
          'The story, narrated · 1–10 min',
          AppRoutes.listen(artworkId),
        ),
      ('Art Detective', 'Find what most visitors miss', AppRoutes.detective),
      if (content.story.isNotEmpty)
        (
          'Deep Dive',
          content.story.map((c) => c.label.toLowerCase()).join(', ')._cap,
          AppRoutes.story(artworkId),
        ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line(.12))),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            ActionRow(
              numeral: romanNumeral(i + 1),
              title: rows[i].$1,
              subtitle: rows[i].$2,
              onTap: () => context.push(rows[i].$3),
            ),
        ],
      ),
    );
  }
}

extension on String {
  String get _cap => isEmpty ? this : this[0].toUpperCase() + substring(1);
}

/// One editorial list row: italic numeral, serif title, arrow.
class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.numeral,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String numeral;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tappable(
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.line(.12))),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                numeral,
                style: AppTypography.serif(
                  22,
                  italic: true,
                ).copyWith(color: p.accent),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.serif(24, height: 1)),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(color: p.muted),
                  ),
                ],
              ),
            ),
            ArtIcon(
              ArtIcons.arrowRight,
              size: 16,
              color: p.muted,
              strokeWidth: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}
