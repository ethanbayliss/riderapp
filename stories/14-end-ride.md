# [RIDER-14] End Ride (Leader Control)

## Type
Story

## Priority
High

## Description
As a ride leader, I want to end the ride for everyone in the group so that the session is formally closed and all riders are returned to the home screen.

## Acceptance Criteria
- [ ] Ride leader sees an "End Ride" button on the live map screen
- [ ] Tapping "End Ride" shows a confirmation dialog before proceeding
- [ ] On confirmation, the ride is marked as inactive in the database
- [ ] All riders in the group receive an audio callout: "The ride has ended"
- [ ] All riders (including the leader) are navigated back to the home screen
- [ ] The ended ride no longer appears as an active ride for any participant
- [ ] Non-leaders do not see the "End Ride" button

## Technical Notes
- Update the `rides` table with an `ended_at` timestamp (or status flag) to mark the ride inactive
- Use Supabase Realtime to broadcast the ride-ended event to all connected clients
- Clients should subscribe to ride status changes and react by navigating home
- On home screen, ended rides should appear greyed out (already handled by existing stale-ride logic)
- Distinguish from RIDER-5 (Leave Ride) — ending removes the ride for everyone; leaving only removes the current user

## Out of Scope
- Scheduled ride end (timer-based)
- Transferring leader role to another rider before ending
- Ride summary screen after ending
