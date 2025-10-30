# Personal Task Manager

A Flutter application for managing personal tasks with a clean architecture approach.

## Features

- **Task Management**
  - View list of tasks with title, description, and completion status
  - Add new tasks
  - Edit existing tasks
  - Delete tasks with confirmation
  - Toggle task completion status
  - Search tasks by title or description
  - Empty state indication when no tasks exist

## Architecture

This application follows a clean, layered architecture pattern organized by features:

### Project Structure

```
lib/
├── features/
│   └── task/
│       ├── application/     # Business logic and state management
│       │   ├── task_provider.dart
│       │   └── add_edit_task_provider.dart
│       ├── data/           # Data layer and repositories
│       │   └── task_repository.dart
│       └── presentation/   # UI components
│           ├── task_list_screen.dart
│           └── add_edit_task_screen.dart
├── models/                # Domain models
│   ├── task.dart
│   └── task.g.dart
└── services/             # Core services
    └── hive_service.dart
```

### Layer Responsibilities

1. **Presentation Layer (`presentation/`)**
   - Contains UI components and screens
   - Handles user interactions
   - Uses Riverpod providers to access state and trigger actions
   - No direct data access or business logic

2. **Application Layer (`application/`)**
   - Contains business logic and state management
   - Uses Riverpod for state management
   - Mediates between UI and data layers
   - Handles data transformation and business rules

3. **Data Layer (`data/`)**
   - Manages data operations through repositories
   - Implements data persistence using Hive
   - Abstracts data source details from the rest of the app

4. **Domain Layer (`models/`)**
   - Contains core business entities
   - Defines data structures used throughout the app
   - Pure Dart classes without dependencies

### State Management

The application uses Riverpod for state management with the following providers:

- `taskListProvider`: Manages the list of tasks
- `filteredTasksProvider`: Provides filtered tasks based on search
- `searchQueryProvider`: Manages the search query state
- `addEditTaskProvider`: Handles task creation and editing
- `taskRepositoryProvider`: Provides access to the task repository

### Data Persistence

Data persistence is implemented using Hive, a lightweight and fast NoSQL database:

- Tasks are stored in a Hive box named 'tasks'
- The `TaskRepository` abstracts all Hive operations
- Automatic data persistence when tasks are modified

## Testing

The application includes comprehensive tests:

- **Widget Tests**: Verify UI behavior and integration
- **Provider Tests**: Ensure correct state management
- **Repository Tests**: Validate data operations
