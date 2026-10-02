import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/user_profile.dart';

final userProfileProvider = FutureProvider<UserProfile>(
  (ref) => ref.watch(profileRepositoryProvider).fetchProfile(),
);
