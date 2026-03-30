# Task Flow

Task Flow is a Flutter task management app built for the Flodo take-home assignment under **Mobile Specialist**. The app is local-first, and focuses on polished UI, clear task state transitions, and reliable on-device persistence.

## project Summary

- Track: **Mobile Specialist**
- Stretch Goal: **Debounced search**
- Architecture: **Clean Architecture**
- Persistence: **SQLite + shared_preferences**
- Design Direction: **Stitch-inspired editorial UI**

## Implemented Features

- Create, read, update, and delete tasks
- Search tasks by title with debounced filtering
- Filter tasks by status: `All`, `To-Do`, `In Progress`, `Done`
- Optional `Blocked By` dependency between tasks
- Blocked task styling and interaction guards until the prerequisite task is marked `Done`
- Draft recovery for unsaved create-task and edit-task input
- Simulated 2-second delay on create and update with visible loading state
- Save button protection against duplicate taps
- Mutation overlay during delayed task updates from the task list
- Left-swipe workflow on task cards:
  - `To-Do` -> `In Progress`
  - `In Progress` -> `Done`
  - `Done` -> delete

## Architecture

The app follows a lightweight Clean Architecture structure:

```text
lib/
  app/
    theme/
  features/tasks/
    data/
    models/
    repositories/
    utils/
    viewmodels/
    views/
```

### Layer Overview

- `models`: task entities, status enum, and draft model
- `data`: SQLite and draft-storage services
- `repositories`: task persistence and simulated save/update delay
- `viewmodels`: screen state, filtering, validation, and actions
- `views`: screens and reusable UI widgets

## Persistence

- Task records are stored in a local SQLite database
- Unsaved create-form and edit-form draft data are stored using `shared_preferences`
- Data persists across app restarts

## How To Run

```bash
flutter pub get
flutter run
```

## Verification

```bash
flutter analyze
flutter test
```

## Notes On Scope

- `Home` is the fully functional assignment screen
- `Calendar` and `Profile` are lightweight placeholders kept to match the UI direction without adding unnecessary scope
- The task detail modal was adapted from the Stitch mockup and simplified to assignment-relevant data only

## Technical Decisions

- **SQLite for tasks**: chosen for durable structured local storage and restart persistence
- **shared_preferences for drafts**: simple and reliable for restoring unsaved form input in both create and edit flows
- **MVVM**: keeps UI, state handling, and persistence responsibilities separated and easier to reason about
- **Blocked task validation**: prevents invalid dependency behavior and blocks status progression until prerequisites are complete
- **Debounced search**: reduces unnecessary filter churn while the user is still typing

## AI Usage Report

AI tools were used to accelerate planning, architecture setup, and implementation scaffolding.

Helpful uses:

- converting the assignment requirements into an MVVM implementation plan
- translating Stitch UI direction into Flutter widgets and screens
- scaffolding repository, view model, and test structure

One correction made after AI-assisted generation:

- an early database startup path and dependency-state iteration needed correction during verification
- blocked-task completion paths, draft restoration coverage, and async list-mutation feedback were tightened during verification
- the issues were fixed after local testing and `flutter analyze`, then revalidated with tests
