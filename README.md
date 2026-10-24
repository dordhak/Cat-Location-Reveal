# 🐱 Cat Map

Cat Location Reveal is a Flutter app for sharing cat sightings on a live map.
Users can create an account, manage a public display name and avatar, view
nearby sightings, and submit cat photos, details, and pin locations. Each
sighting is attributed to the poster's profile.

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
│   ├── auth/
│   │   ├── data/                     # Supabase email/password auth repository
│   │   ├── presentation/screens/     # Sign-in and registration UI
│   │   └── providers/                # Auth session and current-user state
│   ├── cat_sightings/
│   │   ├── data/                     # Model + repository (Supabase I/O)
│   │   ├── providers/                # Location/list/submission state
│   │   └── presentation/             # Screens + widgets
│   └── profile/
│       ├── data/                     # Profile model + avatar/profile repository
│       ├── providers/                # Current profile state
│       └── presentation/screens/     # Edit profile UI
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
3. **Auth:** enable email/password sign-in
4. **Policies:** allow reading sightings and allow users to create/manage only their own uploads/rows (based on `user_id` and storage path `{userId}/{file}`)

Apply the checked-in migration at
`supabase/migrations/20261008000000_profiles_storage_and_sightings_policies.sql`
to the same Supabase project used by the app. It creates/backfills the
`profiles.username` column, refreshes the PostgREST schema cache, configures
avatar upsert policies, and allows public reads of sightings. Without applying
this migration, the Flutter code can still report missing-column or RLS errors.

## Map setup

Android and iOS use Google Maps and require platform API keys in:

- `/home/runner/work/Cat-Location-Reveal/Cat-Location-Reveal/android/app/src/main/AndroidManifest.xml`
- `/home/runner/work/Cat-Location-Reveal/Cat-Location-Reveal/ios/Runner/AppDelegate.swift`

Replace those values with your own API key(s) before production use.
The web app uses OpenStreetMap tiles through `flutter_map`, so it does not
require a Google Maps web key or a billing-enabled Google Cloud project.
OpenStreetMap attribution is displayed on the map; use a dedicated tile
provider for high-volume production traffic.

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

### Web and iPhone PWA testing

```bash
flutter run -d chrome --dart-define-from-file=env.json
```

The GitHub Pages deployment is configured in
`.github/workflows/web-deploy.yml` and publishes at
`https://dordhak.github.io/Cat-Location-Reveal/`. Add these repository
secrets before deploying: `SUPABASE_URL` and `SUPABASE_ANON_KEY`. Enable
GitHub Pages with **GitHub Actions** as the source.
On iPhone, open the deployed URL in Safari and choose **Share > Add to Home
Screen**.

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
