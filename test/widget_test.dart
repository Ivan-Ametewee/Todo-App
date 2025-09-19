import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/models/tag_enum.dart';
import 'package:todo_app/data/local/database_helper.dart';
import 'package:todo_app/data/services/image_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('Task Model Tests', () {
    test('Task creation and serialization', () {
      final task = Task(
        name: 'Test Task',
        description: 'Test Description',
        tag: Tag.work,
        deadline: DateTime.now().add(const Duration(days: 1)),
        notifyBefore: const Duration(hours: 1),
      );

      expect(task.name, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.tag, Tag.work);
      expect(task.isDone, false);
      expect(task.imagePath, null);
    });

    test('Task toMap and fromMap', () {
      final originalTask = Task(
        id: 1,
        name: 'Test Task',
        description: 'Test Description',
        tag: Tag.personal,
        deadline: DateTime(2024, 12, 25, 10, 30),
        notifyBefore: const Duration(minutes: 30),
        isDone: true,
        imagePath: '/test/path.jpg',
      );

      final taskMap = originalTask.toMap();
      final recreatedTask = Task.fromMap(taskMap);

      expect(recreatedTask.id, originalTask.id);
      expect(recreatedTask.name, originalTask.name);
      expect(recreatedTask.description, originalTask.description);
      expect(recreatedTask.tag, originalTask.tag);
      expect(recreatedTask.deadline, originalTask.deadline);
      expect(recreatedTask.notifyBefore, originalTask.notifyBefore);
      expect(recreatedTask.isDone, originalTask.isDone);
      expect(recreatedTask.imagePath, originalTask.imagePath);
    });

    test('Task copyWith method', () {
      final originalTask = Task(
        id: 1,
        name: 'Original Task',
        description: 'Original Description',
        tag: Tag.work,
        deadline: DateTime.now(),
        notifyBefore: const Duration(hours: 1),
      );

      final updatedTask = originalTask.copyWith(
        name: 'Updated Task',
        isDone: true,
      );

      expect(updatedTask.name, 'Updated Task');
      expect(updatedTask.isDone, true);
      expect(updatedTask.description, originalTask.description); // unchanged
      expect(updatedTask.tag, originalTask.tag); // unchanged
    });
  });

  group('Tag Enum Tests', () {
    test('Tag enum values and display names', () {
      expect(Tag.business.displayName, 'Business');
      expect(Tag.work.displayName, 'Work');
      expect(Tag.school.displayName, 'School');
      expect(Tag.personal.displayName, 'Personal');
      expect(Tag.other.displayName, 'Other');
    });

    test('Tag fromString conversion', () {
      expect(Tag.fromString('business'), Tag.business);
      expect(Tag.fromString('WORK'), Tag.work);
      expect(Tag.fromString('School'), Tag.school);
      expect(Tag.fromString('unknown'), Tag.other); // fallback
      expect(Tag.fromString(''), Tag.other); // fallback
    });

    test('Tag toString method', () {
      expect(Tag.business.toString(), 'Business');
      expect(Tag.work.toString(), 'Work');
    });
  });

  group('Database Helper Tests', () {
    late DatabaseHelper databaseHelper;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      databaseHelper = DatabaseHelper();
    });

    tearDown(() async {
      await databaseHelper.closeDatabase();
    });

    test('Database initialization', () async {
      final db = await databaseHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, true);
    });

    test('Insert and retrieve task', () async {
      final task = Task(
        name: 'Database Test Task',
        description: 'Testing database operations',
        tag: Tag.work,
        deadline: DateTime.now().add(const Duration(days: 1)),
        notifyBefore: const Duration(hours: 2),
      );

      // Insert task
      final taskId = await databaseHelper.insertTask(task);
      expect(taskId, greaterThan(0));

      // Retrieve tasks
      final tasks = await databaseHelper.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.name, task.name);
      expect(tasks.first.id, taskId);
    });

    test('Update task', () async {
      // Insert initial task
      final task = Task(
        name: 'Original Name',
        description: 'Original Description',
        tag: Tag.personal,
        deadline: DateTime.now().add(const Duration(days: 1)),
        notifyBefore: const Duration(hours: 1),
      );

      final taskId = await databaseHelper.insertTask(task);
      final insertedTask = task.copyWith(id: taskId);

      // Update task
      final updatedTask = insertedTask.copyWith(
        name: 'Updated Name',
        isDone: true,
      );

      final updateResult = await databaseHelper.updateTask(updatedTask);
      expect(updateResult, 1); // 1 row affected

      // Verify update
      final tasks = await databaseHelper.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.name, 'Updated Name');
      expect(tasks.first.isDone, true);
    });

    test('Delete task', () async {
      // Insert task
      final task = Task(
        name: 'Task to Delete',
        description: 'This task will be deleted',
        tag: Tag.other,
        deadline: DateTime.now().add(const Duration(days: 1)),
        notifyBefore: const Duration(minutes: 30),
      );

      final taskId = await databaseHelper.insertTask(task);

      // Delete task
      final deleteResult = await databaseHelper.deleteTask(taskId);
      expect(deleteResult, 1); // 1 row affected

      // Verify deletion
      final tasks = await databaseHelper.getTasks();
      expect(tasks.length, 0);
    });
  });

  group('Image Service Tests', () {
    test('Image path validation', () {
      final imageService = ImageService();

      expect(imageService.isValidImagePath(null), false);
      expect(imageService.isValidImagePath(''), false);
      expect(imageService.isValidImagePath('/nonexistent/path.jpg'), false);
    });
  });
}