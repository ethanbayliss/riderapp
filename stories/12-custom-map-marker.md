# [RIDER-12] Custom Map Marker

## Type
Story

## Priority
Low

## Description
As a rider, I want to choose a custom icon to represent me on the group map so that I am easily identifiable to other riders in the group.

## Acceptance Criteria
- [ ] User can select a marker icon from a predefined set (e.g. different bike types, helmet, star)
- [ ] Selected icon is shown as their marker on the Live Map for all group members
- [ ] Icon preference is saved and persists across sessions and rides
- [ ] Icon can be changed from the Settings screen
- [ ] Default icon is used if no preference has been set

## Technical Notes
- Store icon preference in Supabase user metadata (alongside `display_name`) or a `user_profiles` table
- Icon set should be Flutter/Material icons or a small bundled SVG set — no external assets required
- The selected icon replaces the current generic bike/person icon in the `CircleAvatar` marker on the Live Map

## Out of Scope
- Custom uploaded images or avatars
- Animated markers
- Colour customisation (marker colour is determined by role: own=primary, others=secondary)
