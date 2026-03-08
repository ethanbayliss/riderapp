# [RIDER-10] Audio Callouts for Group Events

## Type
Story

## Priority
High

## Description
As a rider, I want to hear audio announcements for key group events so that I can stay informed without looking at my screen while riding.

## Acceptance Criteria
- [x] Audio callout plays when a rider joins: *"[Name] has joined the ride"*
- [x] Audio callout plays when a rider leaves: *"[Name] has left the ride"*
- [x] Audio callout plays when the destination is set: *"New destination: [Place Name]"*
- [x] Audio callout plays when a rider arrives at the destination: *"[Name] has arrived"*
- [x] Audio callout plays when all riders have arrived: *"All riders have arrived"*
- [x] Callouts play through the device speaker and any connected Bluetooth audio (helmet intercom, headset)
- [x] Callouts do not interrupt each other — queue and play sequentially
- [x] User can mute callouts in settings without leaving the ride
- [x] Callouts respect device volume

## Technical Notes
- Uses `flutter_tts` package for cross-platform TTS
- `AudioCalloutService` is a singleton with a `Queue<String>` processed sequentially
- Join/leave detection compares rider ID sets on each realtime location update
- Arrival triggered when any rider's GPS is within 100m of the current destination
- Mute toggle shared via singleton; persists for the duration of the app session

## Out of Scope
- Custom callout voices or accents
- Callout for every location update
- In-app volume control (use device volume)
