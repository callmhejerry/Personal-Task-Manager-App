import 'package:personal_task_manager/models/task.dart';

class TaskState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Task> get filteredTasks {
    if (searchQuery.isEmpty) {
      return tasks;
    }
    final query = searchQuery.toLowerCase();
    return tasks.where((task) {
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
    }).toList();
  }
}
