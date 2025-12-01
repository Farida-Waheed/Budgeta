// lib/core/models/user_profile.dart
class UserProfile {
  final String id;
  final String name;
  final int? age;
  final String? country;
  final String? currency;
  final String? avatarUrl;
  final bool prefersArabic;
  final bool notificationsEnabled;

  UserProfile({
    required this.id,
    required this.name,
    this.age,
    this.country,
    this.currency,
    this.avatarUrl,
    this.prefersArabic = false,
    this.notificationsEnabled = true,
  });
}
