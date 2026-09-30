import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/cat_sightings/presentation/screens/map_screen.dart';

/// No auth gate here anymore — the map is public. Only the "Spot a cat"
/// action (in MapScreen) checks sign-in status and routes to AuthScreen
/// first if needed. See MapScreen._onSpotACatPressed.
class CatLocationRevealApp extends StatelessWidget {
  const CatLocationRevealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Location Reveal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MapScreen(),
    );
  }
}