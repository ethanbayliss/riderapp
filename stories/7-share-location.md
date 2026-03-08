# [RIDER-7] Share Real-Time Location

## Type
Story

## Priority
High

## Description
As a rider in an active group, I want my GPS location to be automatically shared with the group so that other riders can see where I am on the map.

## Acceptance Criteria
- [x] Location sharing starts automatically when the user joins or creates a ride
- [x] Location is broadcast to the group every 3-5 seconds while the ride is active
- [x] User can see their own position on the map
- [x] Location sharing stops when the user leaves the ride or ends the session
- [x] If location permission is denied, the user is shown a clear explanation and prompted to grant it
- [x] App requests location permission on first ride join if not already granted

## Technical Notes
- Use device GPS (high accuracy mode)
- Background location is required for Android and iOS — this needs appropriate permissions and entitlements
- On iOS: request "Always" location permission with explanation that it's needed for riding
- On Android: foreground service with persistent notification required for background location
- Battery optimisation: use fused location provider on Android

## Out of Scope
- Manual location spoofing / privacy mode
- Location history logging
