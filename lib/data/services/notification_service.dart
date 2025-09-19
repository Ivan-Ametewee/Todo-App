import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Platform channel for exact alarm permission
  static const platform = MethodChannel('com.example.todo_app/exact_alarms');

  NotificationService._internal();

  factory NotificationService() => _instance;

  Future<void> initialize() async {
    try {
      // Initialize timezone data
      tz_data.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Request permissions
      await _requestPermissions();
      // print('Notification service initialized successfully');
    } catch (e) {
      // print('Error initializing notifications: $e');
      // Don't rethrow - app should continue even if notifications fail
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      // Request notification permission
      final notificationPermission = await Permission.notification.request();
      // print('Notification permission: $notificationPermission');

      // Request exact alarm permission for Android 12+
      await _requestExactAlarmPermission();

      return notificationPermission == PermissionStatus.granted;
    } catch (e) {
      // print('Error requesting permissions: $e');
      return false;
    }
  }

  Future<bool> _requestExactAlarmPermission() async {
    try {
      // For Android 12+ (API 31+), we need exact alarm permission
      final result = await platform.invokeMethod('requestExactAlarmPermission');
      return result == true;
    } on PlatformException {
      return false;
    } catch (e) {
      // print('Error requesting exact alarm permission: $e');
      return false;
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      final result = await platform.invokeMethod('canScheduleExactAlarms');
      return result == true;
    } catch (e) {
      // Error checking exact alarm permission - handle silently
      return false;
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleTaskNotifications(Task task) async {
    if (task.id == null) return;

    final now = DateTime.now();
    bool canScheduleExact = await canScheduleExactAlarms();

    if (!canScheduleExact) {
      // Cannot schedule exact alarms - falling back to approximate scheduling
      await _scheduleApproximateNotifications(task, now);
      return;
    }

    // Schedule reminder notification (before deadline)
    if (task.notifyBefore.inMinutes > 0) {
      final reminderDate = task.deadline.subtract(task.notifyBefore);

      if (reminderDate.isAfter(now)) {
        await _scheduleNotification(
          id: task.id! * 10,
          title: '⏰ Task Reminder',
          body:
              'Your task "${task.name}" is due ${_formatTimeUntil(task.notifyBefore)}!',
          scheduledDate: reminderDate,
          payload: 'reminder_${task.id}',
          useExactTiming: true,
        );
        // Reminder scheduled for task at specified date
      }
    }

    // Schedule due notification (at deadline)
    if (task.deadline.isAfter(now)) {
      await _scheduleNotification(
        id: task.id! * 10 + 1,
        title: '🚨 Task Due Now!',
        body: 'Your task "${task.name}" is due now!',
        scheduledDate: task.deadline,
        payload: 'due_${task.id}',
        useExactTiming: true,
      );
      // Due notification scheduled for task at deadline
    }
  }

  Future<void> _scheduleApproximateNotifications(
      Task task, DateTime now) async {
    // Use inexact scheduling as fallback
    if (task.notifyBefore.inMinutes > 0) {
      final reminderDate = task.deadline.subtract(task.notifyBefore);
      if (reminderDate.isAfter(now)) {
        await _scheduleNotification(
          id: task.id! * 10,
          title: '⏰ Task Reminder',
          body: 'Your task "${task.name}" is due soon!',
          scheduledDate: reminderDate,
          payload: 'reminder_${task.id}',
          useExactTiming: false,
        );
      }
    }

    if (task.deadline.isAfter(now)) {
      await _scheduleNotification(
        id: task.id! * 10 + 1,
        title: '🚨 Task Due',
        body: 'Your task "${task.name}" is due!',
        scheduledDate: task.deadline,
        payload: 'due_${task.id}',
        useExactTiming: false,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    bool useExactTiming = true,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'task_notifications',
        'Task Notifications',
        channelDescription: 'Notifications for task reminders and due dates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      if (useExactTiming) {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          platformDetails,
          payload: payload,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        // Use show with delay as fallback for approximate timing
        final delay = scheduledDate.difference(DateTime.now());
        if (delay.inSeconds > 0) {
          Future.delayed(delay, () async {
            await _notificationsPlugin.show(id, title, body, platformDetails,
                payload: payload);
          });
        }
      }
    } catch (e) {
      // Failed to schedule notification - handle silently
    }
  }

  Future<void> cancelTaskNotifications(int taskId) async {
    try {
      await _notificationsPlugin.cancel(taskId * 10);
      await _notificationsPlugin.cancel(taskId * 10 + 1);
      // Successfully cancelled notifications for task
    } catch (e) {
      // Failed to cancel notifications for task - handle silently
    }
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      999,
      'Test Notification',
      'This notification was sent at ${DateTime.now()}',
      platformDetails,
    );
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.inDays > 0) {
      return 'in ${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return 'in ${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else {
      return 'in ${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    }
  }
}
