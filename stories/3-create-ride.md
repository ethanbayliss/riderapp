# [RIDER-3] Create a Ride Group

## Type
Story

## Priority
High

## Description
As a ride leader, I want to create a ride group and receive an invite code so that I can share it with other riders and have them join my ride.

## Acceptance Criteria
- [x] Authenticated user can create a new ride from the Home screen
- [x] User must provide a ride name (e.g. "Sunday Morning Run")
- [x] On creation, a unique 6-character alphanumeric invite code is generated (e.g. `ABC123`)
- [x] Invite code is displayed prominently and can be copied to clipboard with one tap
- [x] Creator is automatically assigned the Ride Leader role
- [x] Creator is taken to the Live Map screen after creation
- [x] Ability to join multiple rides at the same time

## Technical Notes
- Invite codes should be unique, uppercase, and avoid ambiguous characters (0/O, 1/I)
- Ride remains active until the leader ends it
- Code should be short enough to verbally share with other riders

## Out of Scope
- Scheduled/future rides
- Ride visibility settings (public/private)
- Maximum rider limits
