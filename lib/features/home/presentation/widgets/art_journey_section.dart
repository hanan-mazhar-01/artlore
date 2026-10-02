import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../journey/presentation/journey_providers.dart';
import '../../../profile/presentation/widgets/profile_widgets.dart';

/// "Your art journey" — three numbers and a way into the visitor's taste.
class ArtJourneySection extends ConsumerWidget {
  const ArtJourneySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(artJourneyProvider.select((j) => j.value?.stats));
    if (stats == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 46, 24, 0),
      child: ArtWorldStats(
        stats: stats,
        title: 'Your art journey',
        labels: (
          'artworks\nexplored',
          'artists\ndiscovered',
          'movements\nencountered',
        ),
        footer: Align(
          alignment: Alignment.centerLeft,
          child: ArrowLink(
            label: 'View your journey',
            onTap: () => context.push(AppRoutes.personality),
          ),
        ),
      ),
    );
  }
}
