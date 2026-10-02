class UserProfile {
  final String id;
  final String? username;
  final String? avatarUrl;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    this.username,
    this.avatarUrl,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        username: json['username'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
      );
}