# App Development Plan

This document outlines the incremental steps to build the personal task management app.

**Step 1: Project Setup and Dependencies**
- [x] Add necessary dependencies to `pubspec.yaml` (flutter_riverpod, hive, hive_flutter, build_runner, hive_generator).
- [x] Create basic folder structure for the app (e.g., `lib/features`, `lib/models`, `lib/services`).
- [x] Create a placeholder `main.dart` to initialize the app.
- [x] **Test:** The app should compile and run without errors.

**Step 2: Task Model and Data Layer**
- [x] Create the `Task` model class with `title`, `description`, and `isCompleted` fields.
- [x] Implement the `Hive` service for data persistence.
- [x] Create a `TaskRepository` to abstract data operations (add, edit, delete, get tasks).
- [x] **Test:** Write unit tests for the `TaskRepository` to ensure data operations work correctly.

**Step 3: Task List Screen - UI**
- [x] Create the UI for the task list screen.
- [x] Display a list of tasks using a `ListView`.
- [x] Each task should show the title, description, and a checkbox for the completion status.
- [x] Implement the empty state UI when there are no tasks.
- [x] **Test:** Write widget tests for the task list screen to verify that it displays tasks correctly and shows the empty state.

**Step 4: State Management for Task List**
- [x] Create a `Riverpod` provider to manage the state of the task list.
- [x] The provider should fetch tasks from the `TaskRepository` and notify the UI of any changes.
- [x] Connect the task list UI to the `Riverpod` provider.
- [x] **Test:** Write tests for the `Riverpod` provider to ensure it manages the state correctly.

**Step 5: Add/Edit Task Screen - UI**
- [x] Create the UI for adding and editing tasks.
- [x] This screen should have `TextField` widgets for the title and description.
- [x] **Test:** Write widget tests for the add/edit task screen to verify the UI elements are present.

**Step 6: Add/Edit Task - Functionality**
- [x] Implement the logic to add a new task or update an existing one.
- [x] Use `Riverpod` to manage the state of the add/edit form.
- [x] When a task is saved, it should be persisted using the `TaskRepository` and the task list should be updated.
- [x] **Test:** Write widget tests to verify that a new task can be added and an existing task can be edited.

**Step 7: Delete Task Functionality**
- [x] Add a delete button to each task in the list.
- [x] When the delete button is pressed, show a confirmation dialog.
- [x] If the user confirms, delete the task from the `TaskRepository` and update the task list.
- [x] **Test:** Write widget tests to verify that a task can be deleted and that the confirmation dialog is shown.

**Step 8: Search Functionality**
- [x] Add a search bar to the task list screen.
- [x] As the user types in the search bar, filter the task list to show only tasks that match the search query.
- [x] **Test:** Write widget tests to verify that the search functionality works correctly.

**Step 9: Architecture Documentation**
- [x] Update the `README.md` to document the chosen architecture (e.g., a layered architecture with presentation, application, and data layers).