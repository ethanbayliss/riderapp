# [RIDER-6] View Group on Live Map

## Type
Story

## Priority
High

## Description
As a rider in an active group, I want to see all other riders' real-time positions on a map so that I know where everyone is during the ride.

## Acceptance Criteria
- [x] Live Map shows all active riders in the group as distinct markers
- [x] Each marker displays the rider's display name
- [x] Map auto-centres on the user's own position on load
- [x] Rider markers update in real-time as riders move (target: within 3 seconds)
- [x] Rider count is shown (e.g. "5 riders")
- [x] Map works in standard and satellite view (toggle)
- [x] If a rider has not updated their location in 60 seconds, their marker appears faded

## Technical Notes
- Use a real-time data layer (e.g. Firebase Realtime DB or WebSockets) for position updates
- Throttle location broadcasts to every 3-5 seconds to balance accuracy vs battery/data
- Map provider: consider Google Maps or Mapbox

## Out of Scope
- Routing/directions between riders
- Rider speed or heading indicator (follow-up)
- Breadcrumb trail of past route
