# [RIDER-15] Ride History

## Type
Story

## Priority
Medium

## Description
As a rider, I want to view a list of past rides I participated in so that I can reference previous sessions and see who I rode with.

## Acceptance Criteria
- [ ] A "History" section or tab is accessible from the home screen
- [ ] Each past ride shows: ride name, date, duration, and number of participants
- [ ] Rides are listed in reverse chronological order (most recent first)
- [ ] Only rides the current user participated in are shown
- [ ] Active rides are not included in history (only ended rides)
- [ ] If no history exists, an appropriate empty state is shown

## Technical Notes
- Query `ride_members` joined with `rides` filtered by `user_id` and `rides.ended_at IS NOT NULL`
- Duration can be derived from `rides.created_at` to `rides.ended_at`
- Participant count from `ride_members` count per ride
- No realtime subscription needed — static query on screen load

## Out of Scope
- Route playback or GPS track recording
- Filtering or searching history
- Exporting ride data
- Ride stats (distance, average speed)
