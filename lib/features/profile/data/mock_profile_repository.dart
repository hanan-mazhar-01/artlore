import '../domain/user_profile.dart';

class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository();

  @override
  Future<UserProfile> fetchProfile() async {
    return const UserProfile(
      name: 'Hanan',
      memberSince: 'March 2026',
      listeningTime: '3 h 12 min',
    );
  }
}
