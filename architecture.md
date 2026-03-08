# Architecture

This document records key technical decisions for the RiderApp project.

## Backend
- **Provider:** Supabase
- **Database:** PostgreSQL (via Supabase)
- **Auth:** Supabase Auth (email/password)
- **Realtime:** Supabase Realtime (for live location and group events)

## Frontend
- **Framework:** Flutter
- **Platforms:** Android (primary), iOS (primary), Web (secondary)
- **UI:** Material Design (Flutter default)
- **State Management:** Flutter built-in (`setState` + `ChangeNotifier` with `ListenableBuilder`)
  - No external state management package — keep it simple
  - `ChangeNotifier` classes for shared app-wide state (auth, active ride)
  - `setState` for local widget state

## Key Packages (to be added as needed)
- `supabase_flutter` — Supabase client
- `flutter_map` + `latlong2` — map rendering using OpenStreetMap tiles (no API key required; chosen over google_maps_flutter to avoid platform key management)
- `geolocator` — device GPS
- `flutter_tts` — text-to-speech audio callouts

## Conventions
- All architectural decisions must be recorded in this file
- New packages require a note here explaining why they were chosen
