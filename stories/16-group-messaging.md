# [RIDER-16] In-Ride Group Messaging

## Type
Story

## Priority
Medium

## Description
As a rider, I want to send short text messages to my ride group from the live map screen so that I can communicate without making phone calls or leaving the app.

## Acceptance Criteria
- [ ] A chat panel is accessible from the live map screen (e.g. via a button or bottom sheet)
- [ ] Riders can type and send short messages to the group
- [ ] Messages are displayed in a scrollable log with sender name and timestamp
- [ ] New incoming messages trigger a subtle audio callout: "[Name] sent a message"
- [ ] Unread message count is shown as a badge on the chat button when the panel is closed
- [ ] Messages are scoped to the active ride — riders in different rides cannot see each other's messages
- [ ] Messages sent before a rider joined are not visible to that rider

## Technical Notes
- Add a `messages` table: `id`, `ride_id`, `user_id`, `content`, `created_at`
- Use Supabase Realtime to subscribe to new messages for the active ride
- Audio callout uses the existing `AudioCalloutService` queue
- Keep messages lightweight — short character limit (e.g. 200 chars)
- Messages do not persist after the ride ends (can be deleted on ride end or simply not queried)

## Out of Scope
- Media/image sharing
- Message reactions or replies
- Read receipts
- Push notifications for messages when app is backgrounded
