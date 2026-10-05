import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/user_profile.dart';

final userProfileProvider =
    AsyncNotifierProvider<UserProfileController, UserProfile>(
  UserProfileController.new,
);

class UserProfileController extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    ref.watch(authStateProvider);
    return ref.watch(profileRepositoryProvider).fetchProfile();
  }

  Future<void> updateName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(name: trimmed));
    }
    await ref.read(profileRepositoryProvider).updateName(trimmed);
  }

  Future<void> deleteAccount() async {
    await ref.read(profileRepositoryProvider).deleteAccount();
  }
}
