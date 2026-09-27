class CatSighting {
  final String id;
  final String userId;
  final String name;
  final String catType;
  final String primaryColor;
  final int friendlinessRating;
  final double latitude;
  final double longitude;
  final String photoUrl;
  final DateTime createdAt;

  const CatSighting({
    required this.id,
    required this.userId,
    required this.name,
    required this.catType,
    required this.primaryColor,
    required this.friendlinessRating,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
    required this.createdAt,
  });

  /// Converts a raw Supabase row (Map) into a CatSighting object.
  factory CatSighting.fromJson(Map<String, dynamic> json) {
    return CatSighting(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      catType: json['cat_type'] as String,
      primaryColor: json['primary_color'] as String,
      friendlinessRating: json['friendliness_rating'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      photoUrl: json['photo_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this object back into a Map for inserting/updating in Supabase.
  /// Note: `id` and `created_at` are excluded — the database generates those.
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'cat_type': catType,
      'primary_color': primaryColor,
      'friendliness_rating': friendlinessRating,
      'latitude': latitude,
      'longitude': longitude,
      'photo_url': photoUrl,
    };
  }

  /// Handy for updating local state after an edit without refetching.
  CatSighting copyWith({
    String? name,
    String? catType,
    String? primaryColor,
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
      friendlinessRating: friendlinessRating ?? this.friendlinessRating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }
}