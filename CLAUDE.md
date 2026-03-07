# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app (Android)
flutter run

# Run web version (WSL) — then open http://localhost:8080 in Windows browser or ctrl + shift + P > Browser: New tab
flutter run -d web-server --web-port 8080

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze (lint)
flutter analyze

# Get dependencies
flutter pub get
```

## Setup

For WSL + Windows Android Studio configuration, see [setup.md](./setup.md). **Always update setup.md when performing any setup, installation, or configuration steps.**

## Feature / User Story Workflow

When asked to add a feature or user story:
1. **Ask for any missing information** before starting work (acceptance criteria, edge cases, design decisions, etc.)
2. **Write a Jira-style ticket** as `stories/<#>-<feature-slug>.md` before writing any code, using this format:

```markdown
# [PROJECT-#] Title

## Type
Story | Bug | Task

## Priority
High | Medium | Low

## Description
As a [user type], I want [goal] so that [reason].

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Technical Notes
Any implementation details, constraints, or considerations.

## Out of Scope
What this ticket explicitly does not cover.
```

3. **Get confirmation** on the ticket before implementing.

## Architecture

This is a Flutter application (`lib/main.dart`) targeting Android, iOS, Linux, and macOS. Currently it is the default Flutter counter scaffold — a single `StatefulWidget` (`MyHomePage`) rendered from the root `MyApp` widget.

- `lib/main.dart` — entry point and all app code (to be expanded)
- `test/widget_test.dart` — widget tests using `flutter_test`
- `analysis_options.yaml` — uses `package:flutter_lints/flutter.yaml` rules
