# [RIDER-11] Speed and Heading Indicator

## Type
Story

## Priority
Medium

## Description
As a rider, I want to see my current speed and heading displayed on the Live Map screen so that I am always aware of my speed and direction while riding.

## Acceptance Criteria
- [ ] Current speed is displayed in km/h as a live-updating overlay on the map
- [ ] Heading (compass direction) is displayed alongside speed (e.g. N, NE, SE)
- [ ] Both indicators update in real time as the device moves
- [ ] Indicators are readable at a glance while riding (large, high-contrast text)
- [ ] When GPS signal is lost, indicators show a clear stale/unavailable state

## Technical Notes
- Source speed and heading from `geolocator` package (already listed as a key package in architecture.md)
- `Position.speed` is in m/s — convert to km/h for display
- `Position.heading` is 0–360° — map to 16-point compass or show degrees
- Update interval should match location broadcast frequency from RIDER-7
- Overlay should not obscure the map or the invite code button

## Out of Scope
- Speed limit warnings
- Trip odometer / distance travelled
- Other riders' speed or heading
