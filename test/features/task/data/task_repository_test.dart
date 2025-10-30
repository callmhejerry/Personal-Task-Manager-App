import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_task_manager/features/task/data/task_repository.dart';
import 'package:personal_task_manager/models/task.dart';

import 'task_repository_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  group('TaskRepository', () {
    late TaskRepository taskRepository;
    late MockBox<Task> mockTaskBox;

    setUp(() {
      mockTaskBox = MockBox<Task>();
      taskRepository = TaskRepository(mockTaskBox);
    });

    test('getTasks returns a list of tasks', () {
      final tasks = [
        Task(title: 'Task 1', description: 'Description 1'),
        Task(title: 'Task 2', description: 'Description 2'),
      ];
      when(mockTaskBox.values).thenReturn(tasks);

      final result = taskRepository.getTasks();

      expect(result, equals(tasks));
    });

    test('addTask adds a task to the box', () async {
      final task = Task(title: 'New Task', description: 'New Description');
      when(mockTaskBox.add(task)).thenAnswer((_) async => 0);

      await taskRepository.addTask(task);

      verify(mockTaskBox.add(task));
    });

    test('updateTask updates a task in the box', () async {
      final task = Task(title: 'Updated Task', description: 'Updated Description');
      when(mockTaskBox.putAt(0, task)).thenAnswer((_) async => Future.value());

      await taskRepository.updateTask(0, task);

      verify(mockTaskBox.putAt(0, task));
    });

    test('deleteTask deletes a task from the box', () async {
      when(mockTaskBox.deleteAt(0)).thenAnswer((_) async => Future.value());

      await taskRepository.deleteTask(0);

      verify(mockTaskBox.deleteAt(0));
    });
  });
}
