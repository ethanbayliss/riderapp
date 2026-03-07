# [RIDER-10] Audio Callouts for Group Events

## Type
Story

## Priority
High

## Description
As a rider, I want to hear audio announcements for key group events so that I can stay informed without looking at my screen while riding.

## Acceptance Criteria
- [ ] Audio callout plays when a rider joins: *"[Name] has joined the ride"*
- [ ] Audio callout plays when a rider leaves: *"[Name] has left the ride"*
- [ ] Audio callout plays when the destination is set: *"New destination: [Place Name]"*
- [ ] Audio callout plays when a rider arrives at the destination: *"[Name] has arrived"*
- [ ] Audio callout plays when all riders have arrived: *"All riders have arrived"*
- [ ] Callouts play through the device speaker and any connected Bluetooth audio (helmet intercom, headset)
- [ ] Callouts do not interrupt each other — queue and play sequentially
- [ ] User can mute callouts in settings without leaving the ride
- [ ] Callouts respect device volume

## Technical Notes
- Use text-to-speech (TTS) — Flutter's `flutter_tts` package or platform TTS APIs
- Audio session should be configured to duck (lower) music/media briefly for callout, then restore
- "Arrived" is triggered when a rider's GPS position is within 100m of the destination
- Queue callouts with a short gap between each for clarity

## Out of Scope
- Custom callout voices or accents
- Callout for every location update
- In-app volume control (use device volume)
