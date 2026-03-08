# [RIDER-9] View Next Destination

## Type
Story

## Priority
High

## Description
As a rider in a group, I want to see the next destination on my map and know how far away it is so that I can plan my ride accordingly.

## Acceptance Criteria
- [x] Destination pin is visible on the Live Map for all riders once set
- [x] Destination pin is visually distinct from rider markers (different colour/icon)
- [x] Distance from the rider's current location to the destination is shown (straight-line)
- [x] Destination name or coordinates shown in a banner at the bottom of the map
- [x] Tapping the destination pin shows the full name and an option to open in an external maps app (Google Maps, Apple Maps, Waze)
- [x] If no destination is set, no pin or distance is shown

## Technical Notes
- "Open in maps" deep link should pass the destination coordinates to the external app
- Distance updates as the rider moves

## Out of Scope
- In-app navigation or turn-by-turn directions
- Estimated time of arrival
