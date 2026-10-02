class CatSighting {
  final String id;
  final String userId;
  final String name;
  final String catType;
  final String primaryColor;
  final String? description;
  final int friendlinessRating;
  final double latitude;
  final double longitude;
  final String photoUrl;
  final DateTime createdAt;
  final String? uploaderName;
  final String? uploaderAvatarUrl;

  const CatSighting({
    required this.id,
    required this.userId,
    required this.name,
    required this.catType,
    required this.primaryColor,
    this.description,
    required this.friendlinessRating,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
    required this.createdAt,
    this.uploaderName,
    this.uploaderAvatarUrl,
  });

  factory CatSighting.fromJson(Map<String, dynamic> json) {
    return CatSighting(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      catType: json['cat_type'] as String,
      primaryColor: json['primary_color'] as String,
      description: json['description'] as String?,
      friendlinessRating: json['friendliness_rating'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      photoUrl: json['photo_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      // Only present when the repository's query embeds the `profiles`
      // relationship (see CatSightingRepository.fetchAllSightings).
      uploaderName:
          (json['profiles'] as Map<String, dynamic>?)?['username'] as String?,
      uploaderAvatarUrl:
          (json['profiles'] as Map<String, dynamic>?)?['avatar_url'] as String?,
    );
  }

  /// Excludes `id`, `created_at` (DB-generated) and `uploaderName` (derived
  /// via a join, never written directly).
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'cat_type': catType,
      'primary_color': primaryColor,
      'description': description,
      'friendliness_rating': friendlinessRating,
      'latitude': latitude,
      'longitude': longitude,
      'photo_url': photoUrl,
    };
  }

  CatSighting copyWith({
    String? name,
    String? catType,
    String? primaryColor,
    String? description,
    int? friendlinessRating,
    double? latitude,
    double? longitude,
    String? photoUrl,
  }) {
    return CatSighting(
      id: id,
      userId: userId,
      name: name ?? this.name,
      catType: catType ?? this.catType,
      primaryColor: primaryColor ?? this.primaryColor,
      description: description ?? this.description,
      friendlinessRating: friendlinessRating ?? this.friendlinessRating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      uploaderName: uploaderName,
      uploaderAvatarUrl: uploaderAvatarUrl,
    );
  }
}