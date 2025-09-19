import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/home_screen.dart';
import 'data/services/notification_service.dart';
import 'data/local/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services with error handling
  try {
    // Test database initialization
    final dbHelper = DatabaseHelper();
    await dbHelper.database;
    print('Database initialized successfully');
  } catch (e) {
    print('Database initialization failed: $e');
  }
  
  try {
    await NotificationService().initialize();
    print('Notification service initialized successfully');
  } catch (e) {
    print('Failed to initialize notification service: $e');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}