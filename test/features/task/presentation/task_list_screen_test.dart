import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_task_manager/features/task/application/task_provider.dart';
import 'package:personal_task_manager/features/task/presentation/task_list_screen.dart';
import 'package:personal_task_manager/models/task.dart';

import '../application/task_provider_test.mocks.dart';

void main() {
  group('TaskListScreen', () {
    late MockTaskRepository mockTaskRepository;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      when(mockTaskRepository.getTasks()).thenReturn([]);
    });

    testWidgets('TaskListScreen shows empty state when there are no tasks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(mockTaskRepository.deleteTask(0));
    });

    testWidgets('navigates to edit screen when task is tapped', (
      WidgetTester tester,
    ) async {
      final task = Task(title: 'Task 1', description: 'Description 1');
      when(mockTaskRepository.getTasks()).thenReturn([task]);
      when(mockTaskRepository.updateTask(0, any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      await tester.tap(find.text('Task 1'));
      await tester.pumpAndSettle();

      // Verify that we're on the edit screen
      expect(find.text('Edit Task'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Title'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Description'), findsOneWidget);

      // Verify pre-filled values
      final titleField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Title'),
      );
      final descriptionField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Description'),
      );

      expect(titleField.controller?.text, 'Task 1');
      expect(descriptionField.controller?.text, 'Description 1');
    });

    testWidgets('updates task when edited', (WidgetTester tester) async {
      final task = Task(title: 'Task 1', description: 'Description 1');
      when(mockTaskRepository.getTasks()).thenReturn([task]);
      when(mockTaskRepository.updateTask(0, any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      // Navigate to edit screen
      await tester.tap(find.text('Task 1'));
      await tester.pumpAndSettle();

      // Edit the task
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'Updated Task',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Updated Description',
      );

      // Save changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Verify the update was called with correct data
      verify(mockTaskRepository.updateTask(0, any)).called(1);
    });

    testWidgets('toggles task completion status when checkbox is tapped', (
      WidgetTester tester,
    ) async {
      final task = Task(title: 'Task 1', description: 'Description 1');
      when(mockTaskRepository.getTasks()).thenReturn([task]);
      when(mockTaskRepository.updateTask(0, any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      await tester.drag(find.text('Task 1'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(mockTaskRepository.deleteTask(0)).called(1);
    });
  });
}
