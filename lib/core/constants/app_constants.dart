class AppConstants {
  AppConstants._();

  // Supabase
  static const String catSightingsTable = 'cat_sightings';
  static const String catPhotosBucket = 'cat-photos';

  // Map defaults (used before we get the user's real GPS fix)
  static const double defaultLatitude = 3.1390;   // Kuala Lumpur
  static const double defaultLongitude = 101.6869;
  static const double defaultZoom = 14.0;

  // Form validation
  static const int minFriendlinessRating = 1;
  static const int maxFriendlinessRating = 5;
  static const int maxNameLength = 50;

  // Image
  static const int imageQuality = 80; // compression % for uploads
  static const double maxImageDimension = 1200; // px, resized before upload
}