import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_task_manager/features/task/application/task_provider.dart';
import 'package:personal_task_manager/features/task/application/task_state.dart';
import 'package:personal_task_manager/features/task/data/task_repository.dart';
import 'package:personal_task_manager/features/task/presentation/task_list_screen.dart';
import 'package:personal_task_manager/models/task.dart';

import 'task_list_screen_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('TaskListScreen', () {
    late MockTaskRepository mockTaskRepository;
    late TaskListNotifier taskNotifier;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      when(mockTaskRepository.getTasks()).thenReturn([]);
      taskNotifier = TaskListNotifier(mockTaskRepository);
    });

    Future<void> pumpTaskListScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskStateProvider.overrideWith((ref) => taskNotifier),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('TaskListScreen shows empty state when there are no tasks', (
      WidgetTester tester,
    ) async {
      await pumpTaskListScreen(tester);
      expect(find.text('No tasks yet!'), findsOneWidget);
    });

    testWidgets('TaskListScreen shows a list of tasks', (
      WidgetTester tester,
    ) async {
      final tasks = [
        Task(title: 'Task 1', description: 'Description 1'),
        Task(title: 'Task 2', description: 'Description 2'),
      ];

      when(mockTaskRepository.getTasks()).thenReturn(tasks);

      await pumpTaskListScreen(tester);

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Description 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      expect(find.text('Description 2'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog when delete button is pressed', (
      WidgetTester tester,
    ) async {
      when(
        mockTaskRepository.getTasks(),
      ).thenReturn([Task(title: 'Task 1', description: 'Description 1')]);
      when(mockTaskRepository.deleteTask(0)).thenAnswer((_) async {});

      await pumpTaskListScreen(tester);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Delete Task'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this task?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('deletes task when confirmed in dialog', (
      WidgetTester tester,
    ) async {
      when(
        mockTaskRepository.getTasks(),
      ).thenReturn([Task(title: 'Task 1', description: 'Description 1')]);
      when(mockTaskRepository.deleteTask(0)).thenAnswer((_) async {});

      await pumpTaskListScreen(tester);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(mockTaskRepository.deleteTask(0)).called(1);
    });

    testWidgets('does not delete task when cancelled in dialog', (
      WidgetTester tester,
    ) async {
      when(
        mockTaskRepository.getTasks(),
      ).thenReturn([Task(title: 'Task 1', description: 'Description 1')]);
      when(mockTaskRepository.deleteTask(0)).thenAnswer((_) async {});

      await pumpTaskListScreen(tester);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(mockTaskRepository.deleteTask(0));
    });

    testWidgets('handles task item tap correctly', (WidgetTester tester) async {
      final task = Task(title: 'Task 1', description: 'Description 1');
      when(mockTaskRepository.getTasks()).thenReturn([task]);

      await pumpTaskListScreen(tester);

      await tester.tap(find.text('Task 1'));
      await tester.pumpAndSettle();

      // Verify navigation was attempted
      expect(tester.takeException(), isNull);
    });

    testWidgets('updates task when checkbox is toggled', (
      WidgetTester tester,
    ) async {
      final task = Task(title: 'Task 1', description: 'Description 1');
      when(mockTaskRepository.getTasks()).thenReturn([task]);
      when(mockTaskRepository.updateTask(0, any)).thenAnswer((_) async {});

      await pumpTaskListScreen(tester);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      verify(mockTaskRepository.updateTask(0, any)).called(1);
    });

    testWidgets('simulates edit screen navigation', (
      WidgetTester tester,
    ) async {
      final task = Task(title: 'Task 1', description: 'Description 1');
      when(mockTaskRepository.getTasks()).thenReturn([task]);
      when(mockTaskRepository.updateTask(0, any)).thenAnswer((_) async {});

      await pumpTaskListScreen(tester);

      // Simulate editing the task
      final updatedTask = Task(
        title: 'Updated Task',
        description: 'Updated Description',
        isCompleted: false,
      );
      taskNotifier.updateTask(0, updatedTask);
      await tester.pumpAndSettle();

      // Verify the update was called correctly
      verify(
        mockTaskRepository.updateTask(
          0,
          argThat(
            predicate<Task>(
              (t) =>
                  t.title == 'Updated Task' &&
                  t.description == 'Updated Description',
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets('toggles task completion status when checkbox is tapped', (
      WidgetTester tester,
    ) async {
      final task = Task(title: 'Task 1', description: 'Description 1');
      when(mockTaskRepository.getTasks()).thenReturn([task]);
      when(mockTaskRepository.updateTask(0, any)).thenAnswer((_) async {});

      await pumpTaskListScreen(tester);

      // Find and tap the checkbox
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Verify the update was called with completion status changed
      verify(
        mockTaskRepository.updateTask(
          0,
          argThat(predicate<Task>((task) => task.isCompleted == true)),
        ),
      ).called(1);
    });

    testWidgets('can delete task by swipe', (WidgetTester tester) async {
      when(
        mockTaskRepository.getTasks(),
      ).thenReturn([Task(title: 'Task 1', description: 'Description 1')]);
      when(mockTaskRepository.deleteTask(0)).thenAnswer((_) async {});

      await pumpTaskListScreen(tester);

      await tester.drag(find.text('Task 1'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(mockTaskRepository.deleteTask(0)).called(1);
    });

    testWidgets('handles task loading error', (WidgetTester tester) async {
      when(
        mockTaskRepository.getTasks(),
      ).thenThrow(Exception('Failed to load tasks'));

      taskNotifier.loadTasks();
      await pumpTaskListScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to load tasks'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('handles task deletion error', (WidgetTester tester) async {
      when(
        mockTaskRepository.getTasks(),
      ).thenReturn([Task(title: 'Task 1', description: 'Description 1')]);
      when(
        mockTaskRepository.deleteTask(0),
      ).thenThrow(Exception('Failed to delete task'));

      await pumpTaskListScreen(tester);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(taskNotifier.state.error, isNotNull);
      expect(taskNotifier.state.error, contains('Failed to delete task'));
    });

    testWidgets('handles task update error', (WidgetTester tester) async {
      final task = Task(title: 'Task 1', description: 'Description 1');
      when(mockTaskRepository.getTasks()).thenReturn([task]);
      when(
        mockTaskRepository.updateTask(0, any),
      ).thenThrow(Exception('Failed to update task'));

      await pumpTaskListScreen(tester);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(taskNotifier.state.error, isNotNull);
      expect(taskNotifier.state.error, contains('Failed to update task'));
    });
  });
}
