# [RIDER-13] Single Session Enforcement

## Type
Story

## Priority
Medium

## Description
As a user, I want my account to only be active on one device at a time so that my session cannot be used simultaneously on another device without my knowledge.

## Acceptance Criteria
- [ ] When a user logs in on a second device, the first device's session is immediately invalidated
- [ ] The first device shows a clear message explaining they have been signed out (e.g. "You have been signed in on another device")
- [ ] The first device is returned to the Login screen after session invalidation
- [ ] If the user is in an active ride when signed out, they are cleanly removed from the ride (location cleared, ride_members row deleted)
- [ ] The new (second) login proceeds normally

## Technical Notes
- Supabase Auth supports a `signOut(scope: SignOutScope.others)` call that revokes all other sessions for the current user — call this immediately after sign-in
- To detect invalidation on the first device, listen to `onAuthStateChange` for a `signedOut` event and check the reason; show the displaced-session message only when signed out unexpectedly (i.e. not triggered by the user tapping Log Out)
- The `AuthNotifier` already subscribes to `authStateChanges` — extend it to carry the sign-out reason through to the UI

## Out of Scope
- Session management UI (listing active devices)
- Admin-initiated remote sign-out
- Allowing a configurable number of concurrent sessions
