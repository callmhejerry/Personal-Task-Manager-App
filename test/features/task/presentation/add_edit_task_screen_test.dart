import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_task_manager/features/task/presentation/add_edit_task_screen.dart';
import 'package:personal_task_manager/models/task.dart';

void main() {
  group('AddEditTaskScreen', () {
    testWidgets('renders add task UI correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddEditTaskScreen()));

      expect(
        find.text('Add Task'),
        findsNWidgets(2),
      ); // Once in AppBar, once in button
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders edit task UI correctly', (tester) async {
      final task = Task(title: 'Test Task', description: 'Test Description');

      await tester.pumpWidget(MaterialApp(home: AddEditTaskScreen(task: task)));

      expect(find.text('Edit Task'), findsNWidgets(1));
      expect(find.text('Save Changes'), findsOneWidget);

      // Verify text fields are pre-populated
      final titleField = find.byType(TextField).first;
      final descriptionField = find.byType(TextField).last;

      expect(
        (titleField.evaluate().single.widget as TextField).controller?.text,
        'Test Task',
      );
      expect(
        (descriptionField.evaluate().single.widget as TextField)
            .controller
            ?.text,
        'Test Description',
      );
    });

    testWidgets('shows error when trying to save with empty title', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddEditTaskScreen()));

      // Try to save without entering a title
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Title cannot be empty'), findsOneWidget);
    });

    testWidgets('creates task with entered data', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddEditTaskScreen()));

      // Enter task details
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'New Task',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'New Description',
      );

      // Verify text was entered correctly
      expect(find.text('New Task'), findsOneWidget);
      expect(find.text('New Description'), findsOneWidget);
    });
  });
}
