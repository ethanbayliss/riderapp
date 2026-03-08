# [RIDER-11] Speed and Heading Indicator

## Type
Story

## Priority
Medium

## Description
As a rider, I want to see my current speed and heading displayed on the Live Map screen so that I am always aware of my speed and direction while riding.

## Acceptance Criteria
- [x] Current speed is displayed in km/h as a live-updating overlay on the map
- [x] Heading (compass direction) is displayed alongside speed (e.g. N, NE, SE)
- [x] Both indicators update in real time as the device moves
- [x] Indicators are readable at a glance while riding (large, high-contrast text)
- [x] When GPS signal is lost, indicators show a clear stale/unavailable state

## Technical Notes
- `_SpeedHeadingWidget` positioned bottom-left of the map stack
- Speed: `Position.speed * 3.6` (m/s → km/h), clamped to 0
- Heading: 16-point compass mapped from 0–360° via `(deg / 22.5).round() % 16`
- Shows `-- km/h` and `--` when `_myPosition` is null
- Dark semi-transparent background for contrast over any map tile

## Out of Scope
- Speed limit warnings
- Trip odometer / distance travelled
- Other riders' speed or heading
