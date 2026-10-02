import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/art_scaffold.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/round_buttons.dart';
import '../artwork_providers.dart';
import 'look_closer_view.dart';

/// Look Closer — step inside the canvas, one detail at a time.
class LookCloserScreen extends ConsumerWidget {
  const LookCloserScreen({super.key, required this.artworkId});

  final String artworkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final artwork = ref.watch(artworkProvider(artworkId)).value;
    final content = ref.watch(artworkContentProvider(artworkId));
    return ArtScaffold(
      background: p.deep,
      forceLightStatusBar: true,
      body: AsyncView(
        value: content,
        data: (c) => artwork == null || c.details.isEmpty
            ? const SizedBox.expand()
            : LookCloserView(artwork: artwork, details: c.details),
      ),
    );
  }
}

/// Back · "LOOK CLOSER" · reset, floating over the canvas.
class LookCloserTopBar extends StatelessWidget {
  const LookCloserTopBar({super.key, required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GlassIconButton(
          icon: ArtIcons.chevronLeft,
          onTap: () => context.backOr(),
          semanticLabel: 'Back',
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: p.glass,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const GoldLabel('Look closer', tracking: .24),
        ),
        GlassIconButton(
          icon: ArtIcons.expand,
          iconSize: 17,
          onTap: onReset,
          semanticLabel: 'Show the whole painting',
        ),
      ],
    );
  }
}
