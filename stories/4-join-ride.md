# [RIDER-4] Join a Ride via Invite Code

## Type
Story

## Priority
High

## Description
As a motorcycle rider, I want to join an existing ride group using an invite code so that I can share my location and ride together with the group.

## Acceptance Criteria
- [ ] User can enter an invite code from the Home screen
- [ ] Code input is case-insensitive
- [ ] Invalid or expired codes show a clear error
- [ ] On success, user joins the ride as a Rider and is taken to the Live Map screen
- [ ] All existing group members receive an audio callout: *"[Name] has joined the ride"*
- [ ] Only one active ride per user at a time — joining a new ride requires leaving the current one

## Technical Notes
- Validate code server-side before joining
- Joining should be near-instant — avoid loading states longer than 2 seconds

## Out of Scope
- QR code scanning
- Invite links (URL-based joining)
