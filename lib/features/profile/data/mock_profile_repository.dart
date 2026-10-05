import '../domain/user_profile.dart';

class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository();

  @override
  Future<UserProfile> fetchProfile() async {
    return const UserProfile(
      name: 'Art Visitor',
      memberSince: 'March 2026',
      listeningTime: '0 min',
    );
  }

  @override
  Future<void> updateName(String name) async {}

  @override
  Future<void> deleteAccount() async {}
}
