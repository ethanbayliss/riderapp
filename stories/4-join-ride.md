# [RIDER-4] Join a Ride via Invite Code

## Type
Story

## Priority
High

## Description
As a motorcycle rider, I want to join an existing ride group using an invite code so that I can share my location and ride together with the group.

## Acceptance Criteria
- [x] User can enter an invite code from the Home screen
- [x] Code input is case-insensitive
- [x] Invalid or expired codes show a clear error
- [x] On success, user joins the ride as a Rider and is taken to the Live Map screen
- [x] All existing group members receive an audio callout: *"[Name] has joined the ride"* (stubbed — full TTS in RIDER-10)
- [x] Users can be a member of multiple rides simultaneously

## Technical Notes
- Validate code server-side before joining
- Joining should be near-instant — avoid loading states longer than 2 seconds

## Out of Scope
- QR code scanning
- Invite links (URL-based joining)
