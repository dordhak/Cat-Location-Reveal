/// Soft, low-noise map style: business icons and transit hidden, parks and
/// water tinted to match the app palette, highways picking up a hint of
/// marmalade so the pins stay the most colorful thing on screen.
const String kCatMapStyle = r'''
[
  {"elementType": "geometry", "stylers": [{"color": "#f4efe9"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#6e6273"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#faf7f4"}]},
  {"featureType": "administrative", "elementType": "geometry.stroke", "stylers": [{"color": "#e3d9d0"}]},
  {"featureType": "administrative.land_parcel", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi.park", "stylers": [{"visibility": "on"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#d3e6d0"}]},
  {"featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{"color": "#5f8a5c"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#ffffff"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#ece3da"}]},
  {"featureType": "road.arterial", "elementType": "labels.text.fill", "stylers": [{"color": "#857a8a"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#ffe0b8"}]},
  {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#f3c896"}]},
  {"featureType": "road.local", "elementType": "labels", "stylers": [{"visibility": "simplified"}]},
  {"featureType": "transit", "stylers": [{"visibility": "off"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#bcd9d3"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#5a8a83"}]}
]
''';