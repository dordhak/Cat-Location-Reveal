🐱 Cat Location Reveal

A mobile app where users spot cats in the wild, snap a photo, tag some details, and drop a pin on a shared map so other cat lovers can see where cats have been spotted.

Tech Stack
Frontend: Flutter (Dart)
State Management: Riverpod (code-generated, @riverpod)
Backend: Supabase (Auth, Postgres, Storage)
Maps: google_maps_flutter
Location: geolocator
Media: image_picker
Features
📍 Interactive Google Map centered on the user's current location
🐾 Cat sightings rendered as markers, pulled live from Supabase
📋 Tap a marker to see the cat's photo, name, type, color, friendliness rating, and timestamp
📸 "Spot a Cat" flow: take/pick a photo, fill in details, drag a pin to fine-tune the exact spot
🔒 Anonymous auth — no login screen needed for the MVP; each install gets a stable identity
