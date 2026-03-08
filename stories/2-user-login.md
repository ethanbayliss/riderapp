# [RIDER-2] User Login

## Type
Story

## Priority
High

## Description
As a registered rider, I want to log in to my account so that I can access my rides and groups.

## Acceptance Criteria
- [x] User can log in with email and password
- [x] Invalid credentials show a clear error without revealing which field is wrong
- [x] Successful login takes user to the Home screen
- [x] User session persists between app restarts (stay logged in)
- [x] User can log out from settings

## Technical Notes
- Persist session token securely using device secure storage
- Auto-navigate to Home if a valid session already exists on app launch

## Out of Scope
- Forgot password / password reset (follow-up story)
- Biometric login
