# [RIDER-12] Custom Map Marker

## Type
Story

## Priority
Low

## Description
As a rider, I want to choose a custom icon to represent me on the group map so that I am easily identifiable to other riders in the group.

## Acceptance Criteria
- [x] User can select a marker icon from a predefined set (e.g. different bike types, helmet, star)
- [x] Selected icon is shown as their marker on the Live Map for all group members
- [x] Icon preference is saved and persists across sessions and rides
- [x] Icon can be changed from the Settings screen
- [x] Default icon is used if no preference has been set

## Technical Notes
- Icon preference stored in Supabase user metadata (`marker_icon` key via `auth.updateUser`)
- Predefined set in `lib/models/marker_icons.dart`: motorcycle, two_wheeler, directions_bike, sports_motorsports, local_shipping, bolt, star, local_fire_department
- `marker_icon TEXT NOT NULL DEFAULT 'motorcycle'` added to `rider_locations` table; broadcast with every location upsert so other riders see the correct icon immediately
- `AuthNotifier.updateMarkerIcon()` updates metadata; `AuthNotifier.markerIcon` exposes the current value
- Settings screen shows icon grid picker dialog; LiveMapScreen passes `markerIcon` down from HomeScreen

## Out of Scope
- Custom uploaded images or avatars
- Animated markers
- Colour customisation (marker colour is determined by role: own=primary, others=secondary)
