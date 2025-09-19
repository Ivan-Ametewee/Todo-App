import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task_model.dart';
import '../data/local/database_helper.dart';
import '../data/services/notification_service.dart';

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    // Auto-load tasks when notifier is created
    loadTasks();
  }

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  Future<void> loadTasks() async {
    try {
      print('DEBUG: Loading tasks from database...');
      final tasks = await _databaseHelper.getTasks();
      print('DEBUG: Loaded ${tasks.length} tasks');
      state = tasks;
    } catch (e) {
      print('DEBUG: Error loading tasks: $e');
      state = [];
    }
  }

  Future<bool> addTask(Task task) async {
    try {
      print('DEBUG: Adding task: ${task.name}');
      print('DEBUG: Task data: ${task.toMap()}');
      
      final id = await _databaseHelper.insertTask(task);
      print('DEBUG: Task inserted with ID: $id');
      
      final newTask = task.copyWith(id: id);
      state = [...state, newTask];
      print('DEBUG: Task added to state. Total tasks: ${state.length}');
      
      // Schedule both reminder and due notifications
      try {
        await _notificationService.scheduleTaskNotifications(newTask);
        print('DEBUG: Notifications scheduled for task: ${newTask.name}');
      } catch (e) {
        print('DEBUG: Failed to schedule notifications: $e');
        // Don't fail task creation if notifications fail
      }
      
      return true;
    } catch (e, stackTrace) {
      print('DEBUG: Error adding task: $e');
      print('DEBUG: Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      print('DEBUG: Updating task: ${task.id} - ${task.name}');
      await _databaseHelper.updateTask(task);
      state = [
        for (final t in state)
          if (t.id == task.id) task else t,
      ];
      
      // Reschedule notifications if not completed
      if (task.id != null) {
        try {
          // Cancel existing notifications
          await _notificationService.cancelTaskNotifications(task.id!);
          print('DEBUG: Cancelled existing notifications for task: ${task.id}');
          
          // Schedule new notifications only if task is not done
          if (!task.isDone) {
            await _notificationService.scheduleTaskNotifications(task);
            print('DEBUG: Rescheduled notifications for task: ${task.name}');
          }
        } catch (e) {
          print('DEBUG: Failed to reschedule notifications: $e');
          // Don't fail task update if notifications fail
        }
      }
      
      print('DEBUG: Task updated successfully');
      return true;
    } catch (e) {
      print('DEBUG: Error updating task: $e');
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      print('DEBUG: Deleting task: $id');
      await _databaseHelper.deleteTask(id);
      state = state.where((task) => task.id != id).toList();
      
      // Cancel all notifications for this task
      try {
        await _notificationService.cancelTaskNotifications(id);
        print('DEBUG: Cancelled notifications for deleted task: $id');
      } catch (e) {
        print('DEBUG: Failed to cancel notifications: $e');
        // Don't fail deletion if notification cancellation fails
      }
      
      print('DEBUG: Task deleted successfully');
      return true;
    } catch (e) {
      print('DEBUG: Error deleting task: $e');
      return false;
    }
  }

  Future<bool> markAsDone(int id) async {
    try {
      print('DEBUG: Marking task as done: $id');
      final task = state.firstWhere((t) => t.id == id);
      final updatedTask = task.copyWith(isDone: true);
      
      // Cancel notifications when marked as done
      try {
        await _notificationService.cancelTaskNotifications(id);
        print('DEBUG: Cancelled notifications for completed task: $id');
      } catch (e) {
        print('DEBUG: Failed to cancel notifications: $e');
        // Don't fail completion if notification cancellation fails
      }
      
      return await updateTask(updatedTask);
    } catch (e) {
      print('DEBUG: Error marking task as done: $e');
      return false;
    }
  }

  // Helper method to test notifications
  Future<void> testNotification() async {
    try {
      await _notificationService.showTestNotification();
      print('DEBUG: Test notification sent');
    } catch (e) {
      print('DEBUG: Failed to send test notification: $e');
    }
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});