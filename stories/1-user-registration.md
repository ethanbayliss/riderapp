# [RIDER-1] User Registration

## Type
Story

## Priority
High

## Description
As a motorcycle rider, I want to create an account so that I can access the app and participate in group rides.

## Acceptance Criteria
- [x] User can register with email and password
- [x] When a user is registered they are told to check their email for verification
- [x] Password must meet minimum security requirements (8+ chars)
- [x] User must provide a display name (shown to other riders in the group)
- [x] Duplicate email addresses are rejected with a clear error
- [x] On success, user is logged in and taken to the Home screen

## Technical Notes
- Display name is what other riders see on the map and in audio callouts — keep it short (max 20 chars)
- Store auth via a backend auth service (Firebase Auth or similar)

## Out of Scope
- Social login (Google, Apple)
- Profile photo
- Phone number verification
