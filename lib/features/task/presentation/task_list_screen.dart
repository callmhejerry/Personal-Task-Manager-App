import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_task_manager/features/task/application/task_provider.dart';
import 'package:personal_task_manager/features/task/presentation/add_edit_task_screen.dart';
import 'package:personal_task_manager/models/task.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskStateProvider.notifier).loadTasks();
    });
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void didUpdateWidget(TaskListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final state = ref.read(taskStateProvider);
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(context, state.error!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskStateProvider);
    final tasks = ref.watch(filteredTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) =>
                  ref.read(taskStateProvider.notifier).updateSearchQuery(value),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.of(context).push<Task>(
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
          if (newTask != null) {
            ref.read(taskStateProvider.notifier).addTask(newTask);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(taskStateProvider.notifier).loadTasks();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : tasks.isEmpty
          ? const Center(child: Text('No tasks yet!'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: ValueKey(index),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Task'),
                          content: const Text(
                            'Are you sure you want to delete this task?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    ref.read(taskStateProvider.notifier).deleteTask(index);
                  },
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.description),
                    onTap: () async {
                      final editedTask = await Navigator.of(context).push<Task>(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditTaskScreen(task: task, index: index),
                        ),
                      );
                      if (editedTask != null) {
                        ref
                            .read(taskStateProvider.notifier)
                            .updateTask(index, editedTask);
                      }
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            final updatedTask = Task(
                              title: task.title,
                              description: task.description,
                              isCompleted: value ?? false,
                            );
                            ref
                                .read(taskStateProvider.notifier)
                                .updateTask(index, updatedTask);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Task'),
                                  content: const Text(
                                    'Are you sure you want to delete this task?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldDelete == true) {
                              ref
                                  .read(taskStateProvider.notifier)
                                  .deleteTask(index);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
