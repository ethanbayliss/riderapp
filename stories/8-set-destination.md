# [RIDER-8] Set Next Destination

## Type
Story

## Priority
High

## Description
As a ride leader, I want to set the next destination/meetup point on the map so that all riders know where we are heading next.

## Acceptance Criteria
- [x] Only the Ride Leader can set a destination
- [x] Leader can set destination by long-pressing on the map or searching for a location by name
- [x] Destination is shown as a distinct pin on all riders' maps immediately after being set
- [x] All riders receive an audio callout: *"New destination set: [Place Name or 'a new location']"* (stubbed — full TTS in RIDER-10)
- [x] Leader can update the destination — previous pin is replaced
- [x] Leader can clear the destination
- [x] Place name is used in callout if available from reverse geocoding, otherwise "a new location"
- [x] Past destinations are recorded and viewable by all ride members in a history list

## Technical Notes
- Reverse geocode the dropped pin to get a human-readable name for the audio callout
- Destination is stored on the server and pushed to all connected clients in real-time

## Out of Scope
- Turn-by-turn navigation (riders use their preferred GPS app for that)
- Multiple waypoints / route planning
- ETA calculation
