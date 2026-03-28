# Task Flow

Task Flow is a Flutter task management app built for the Flodo take-home assignment using **Track B (Mobile Specialist)**. It uses a local-first stack, Stitch-inspired editorial UI, and an MVVM architecture with persistent task storage, dependency-aware task states, and draft recovery.

## What Is Included

- Track B implementation with no backend
- MVVM structure with models, data services, repository, view models, and views
- SQLite persistence for tasks
- `shared_preferences` draft persistence for unsaved create-task input
- Search by title and filter by status
- Blocked task styling and dependency handling
- Simulated 2-second create/update delay with disabled save actions
- Stitch-inspired screens for home, empty, loading, error, detail, and create/edit flows

## Project Structure

```text
lib/
  app/
  features/tasks/
    data/
    models/
    repositories/
    utils/
    viewmodels/
    views/
```

## Setup

1. Install Flutter 3.35+ and confirm `flutter doctor` is clean.
2. Open the project folder:

   ```bash
   cd task_flow
   ```

3. Fetch packages:

   ```bash
   flutter pub get
   ```

4. Run the app:

   ```bash
   flutter run
   ```

5. Run verification:

   ```bash
   flutter analyze
   flutter test
   ```

## Assignment Choices

- Track: **Track B**
- Stretch Goal: **None**
- Architecture: **MVVM**
- Persistence: **SQLite + shared_preferences**

## Technical Notes

- Tasks are stored locally in SQLite and persist across app restarts.
- Draft text entered in the create-task flow is restored if the screen is reopened before save.
- The optional `blocked by` relationship is validated to avoid self-references and dependency cycles when editing.
- Create and update actions intentionally wait for 2 seconds so the loading state and double-submit protection are visible.

## AI Usage Report

AI tools were used to accelerate planning, architecture setup, and implementation scaffolding.

Helpful AI usage:
- breaking the assignment into a concrete MVVM architecture
- mapping the Stitch UI references into Flutter widgets
- generating initial repository, view model, and test scaffolding

AI correction example:
- an early pass produced a dependency-cycle utility with an invalid nullable assignment
- the logic was corrected after `flutter analyze` flagged the issue, and the cycle checks were verified with tests
