# 🐱 Cat Location Reveal

Cat Location Reveal is a Flutter app for sharing cat sightings on a live map.
Users can open the app, get anonymous authentication, view nearby sightings, and submit new sightings with a photo, details, and pin location.

## What the app does

- Shows your current location on Google Maps
- Loads cat sightings from Supabase and renders them as map markers
- Opens a detail sheet for each sighting (photo, name, type, color, friendliness, timestamp)
- Lets users submit new sightings:
  - Take a photo or pick one from gallery
  - Fill in cat details
  - Drag a pin to fine-tune the exact spot
  - Upload photo to Supabase Storage and save metadata to Supabase Postgres
- Uses **anonymous Supabase auth** (no login screen for MVP)

## Tech stack

- **Frontend:** Flutter (Dart)
- **State management:** Riverpod + code generation (`@riverpod`)
- **Backend:** Supabase (Auth, Postgres, Storage)
- **Maps:** `google_maps_flutter`
- **Location:** `geolocator`
- **Media:** `image_picker`

## Project structure

```text
lib/
├── main.dart                         # App entry + Supabase init
├── app.dart                          # MaterialApp + auth gate
├── core/
│   ├── config/supabase_config.dart   # Reads SUPABASE_* dart-defines
│   ├── constants/app_constants.dart
│   ├── errors/app_exception.dart
│   └── utils/location_utils.dart
├── features/
│   ├── auth/providers/               # Anonymous auth provider
│   └── cat_sightings/
│       ├── data/                     # Model + repository (Supabase I/O)
│       ├── providers/                # Location/list/submission state
│       └── presentation/             # Screens + widgets
└── shared/widgets/
```

## Prerequisites

- Flutter SDK (matching `sdk: ^3.13.4` from `pubspec.yaml`)
- A Supabase project
- Google Maps API key(s)
- Android Studio / Xcode (for emulator/device runs)

## Backend setup (Supabase)

Create these resources in Supabase:

1. **Table:** `cat_sightings`
   - Expected columns used by the app:
     - `id` (text/uuid)
     - `user_id` (text/uuid)
     - `name` (text)
     - `cat_type` (text)
     - `primary_color` (text)
     - `friendliness_rating` (int)
     - `latitude` (double/float)
     - `longitude` (double/float)
     - `photo_url` (text)
     - `created_at` (timestamp)
2. **Storage bucket:** `cat-photos`
3. **Auth:** enable anonymous sign-in
4. **Policies:** allow reading sightings and allow users to create/manage only their own uploads/rows (based on `user_id` and storage path `{userId}/{file}`)

## Google Maps setup

This project currently uses a key in:

- `/home/runner/work/Cat-Location-Reveal/Cat-Location-Reveal/android/app/src/main/AndroidManifest.xml`
- `/home/runner/work/Cat-Location-Reveal/Cat-Location-Reveal/ios/Runner/AppDelegate.swift`

Replace those values with your own API key(s) before production use.

## How to run

From the repository root:

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

Example (Android emulator):

```bash
flutter run -d emulator-5554 \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

## Optional: regenerate Riverpod files

If you edit `@riverpod` providers:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Permissions used

- **Location:** show your position and tag sightings
- **Camera / Photo Library:** capture or select cat photos
- **Internet:** fetch/save data via Supabase

## Notes

- If location permission is denied, the app shows a user-friendly error state.
- New sightings refresh the map list immediately after a successful submission.
