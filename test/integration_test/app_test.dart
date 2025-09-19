import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_app/main.dart' as app;
//import 'package:todo_app/data/models/task_model.dart';
//import 'package:todo_app/data/models/tag_enum.dart';
//import 'package:todo_app/state/task_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Todo App Integration Tests', () {
    testWidgets('Complete task flow: create, view, edit, complete, delete', 
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Test 1: Create a new task
      await _testCreateTask(tester);
      
      // Test 2: View task in list
      await _testViewTaskInList(tester);
      
      // Test 3: Edit task
      await _testEditTask(tester);
      
      // Test 4: Mark task as complete
      await _testMarkTaskComplete(tester);
      
      // Test 5: Delete task
      await _testDeleteTask(tester);
    });

    testWidgets('Task persistence test', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Create a task
      await _createTestTask(tester, 'Persistence Test');
      
      // Restart the app (simulate app close/reopen)
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );
      
      app.main();
      await tester.pumpAndSettle();
      
      // Verify task still exists
      expect(find.text('Persistence Test'), findsOneWidget);
    });

    testWidgets('Multiple tasks management', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Create multiple tasks
      final taskNames = ['Task 1', 'Task 2', 'Task 3'];
      for (final taskName in taskNames) {
        await _createTestTask(tester, taskName);
      }

      // Verify all tasks appear in list
      for (final taskName in taskNames) {
        expect(find.text(taskName), findsOneWidget);
      }

      // Complete one task
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Delete one task
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Verify correct number of tasks remain
      expect(find.byType(Card), findsNWidgets(2));
    });
  });
}

// Helper method to test task creation
Future<void> _testCreateTask(WidgetTester tester) async {
  // Look for add task button (FloatingActionButton or add button)
  final addButton = find.byType(FloatingActionButton).first;
  expect(addButton, findsOneWidget);
  
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  // Fill in task form
  await tester.enterText(find.byType(TextFormField).first, 'Test Task');
  await tester.enterText(find.byType(TextFormField).at(1), 'Test Description');
  
  // Save the task
  await tester.tap(find.text('Save').first);
  await tester.pumpAndSettle();

  // Verify task appears in list
  expect(find.text('Test Task'), findsOneWidget);
}

// Helper method to test viewing task in list
Future<void> _testViewTaskInList(WidgetTester tester) async {
  // Verify task card elements are visible
  expect(find.text('Test Task'), findsOneWidget);
  expect(find.text('Test Description'), findsOneWidget);
  
  // Tap on task to open details
  await tester.tap(find.text('Test Task'));
  await tester.pumpAndSettle();
  
  // Verify we're in detail view (look for back button or detail elements)
  expect(find.byIcon(Icons.arrow_back), findsOneWidget);
}

// Helper method to test editing task
Future<void> _testEditTask(WidgetTester tester) async {
  // Look for edit button
  final editButton = find.byIcon(Icons.edit);
  if (editButton.evaluate().isNotEmpty) {
    await tester.tap(editButton);
    await tester.pumpAndSettle();
    
    // Edit the task name
    await tester.enterText(find.byType(TextFormField).first, 'Updated Test Task');
    
    // Save changes
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    
    // Verify changes are reflected
    expect(find.text('Updated Test Task'), findsOneWidget);
  }
}

// Helper method to test marking task as complete
Future<void> _testMarkTaskComplete(WidgetTester tester) async {
  // Find and tap the checkbox/completion button
  final checkboxFinder = find.byType(GestureDetector);
  
  if (checkboxFinder.evaluate().isNotEmpty) {
    await tester.tap(checkboxFinder.first);
    await tester.pumpAndSettle();
    
    // Verify task is marked as complete (look for checkmark or styling changes)
    expect(find.byIcon(Icons.check), findsOneWidget);
  }
}

// Helper method to test deleting task
Future<void> _testDeleteTask(WidgetTester tester) async {
  // Find and tap delete button
  final deleteButton = find.byIcon(Icons.delete_outline);
  expect(deleteButton, findsOneWidget);
  
  await tester.tap(deleteButton);
  await tester.pumpAndSettle();
  
  // Confirm deletion if there's a dialog
  final confirmButton = find.text('Delete');
  if (confirmButton.evaluate().isNotEmpty) {
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();
  }
  
  // Verify task is removed from list
  expect(find.text('Updated Test Task'), findsNothing);
}

// Helper method to create a test task with given name
Future<void> _createTestTask(WidgetTester tester, String taskName) async {
  // Tap add button
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Fill form
  await tester.enterText(find.byType(TextFormField).first, taskName);
  await tester.enterText(find.byType(TextFormField).at(1), 'Description for $taskName');
  
  // Save task
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}