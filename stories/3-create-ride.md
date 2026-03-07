# [RIDER-3] Create a Ride Group

## Type
Story

## Priority
High

## Description
As a ride leader, I want to create a ride group and receive an invite code so that I can share it with other riders and have them join my ride.

## Acceptance Criteria
- [ ] Authenticated user can create a new ride from the Home screen
- [ ] User must provide a ride name (e.g. "Sunday Morning Run")
- [ ] On creation, a unique 6-character alphanumeric invite code is generated (e.g. `ABC123`)
- [ ] Invite code is displayed prominently and can be copied to clipboard with one tap
- [ ] Creator is automatically assigned the Ride Leader role
- [ ] Creator is taken to the Live Map screen after creation
- [ ] Only one active ride per user at a time

## Technical Notes
- Invite codes should be unique, uppercase, and avoid ambiguous characters (0/O, 1/I)
- Ride remains active until the leader ends it
- Code should be short enough to verbally share with other riders

## Out of Scope
- Scheduled/future rides
- Ride visibility settings (public/private)
- Maximum rider limits
