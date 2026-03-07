# [RIDER-5] Leave a Ride

## Type
Story

## Priority
High

## Description
As a rider, I want to leave a ride group so that my location is no longer shared and I am removed from the group map.

## Acceptance Criteria
- [ ] Any rider can leave a ride at any time from the Live Map screen
- [ ] Confirmation prompt shown before leaving to prevent accidental exit
- [ ] On leave, rider is removed from the map for all other group members
- [ ] Remaining group members receive an audio callout: *"[Name] has left the ride"*
- [ ] User is returned to the Home screen after leaving
- [ ] If the Ride Leader leaves, the ride ends for all participants with a notification

## Technical Notes
- Stop broadcasting location immediately on leave
- Handle app being closed/killed as an implicit leave — use presence/heartbeat mechanism

## Out of Scope
- Transferring ride leadership to another rider
- Kicking riders from a group
