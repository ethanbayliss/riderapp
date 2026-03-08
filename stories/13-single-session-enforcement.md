# [RIDER-13] Single Session Enforcement

## Type
Story

## Priority
Medium

## Description
As a user, I want my account to only be active on one device at a time so that my session cannot be used simultaneously on another device without my knowledge.

## Acceptance Criteria
- [x] When a user logs in on a second device, the first device's session is immediately invalidated
- [x] The first device shows a clear message explaining they have been signed out (e.g. "You have been signed in on another device")
- [x] The first device is returned to the Login screen after session invalidation
- [x] If the user is in an active ride when signed out, they are cleanly removed from the ride (location cleared, ride_members row deleted)
- [x] The new (second) login proceeds normally

## Technical Notes
- `AuthService.login()` calls `signOut(scope: SignOutScope.others)` immediately after sign-in
- `AuthNotifier` listens to `onAuthStateChange`; sets `displacedSession = true` on unexpected `signedOut` events (distinguished from intentional logout via `_intentionalLogout` flag)
- `LoginScreen` shows an error banner when `authNotifier.displacedSession` is true
- `LiveMapScreen` listens to `onAuthStateChange` directly; on any `signedOut` event, cancels all subscriptions and pops to the first route

## Out of Scope
- Session management UI (listing active devices)
- Admin-initiated remote sign-out
- Allowing a configurable number of concurrent sessions
