import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/art_journey.dart';

final artJourneyProvider = FutureProvider<ArtJourney>(
  (ref) => ref.watch(journeyRepositoryProvider).fetchJourney(),
);
