import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/screens/home_screen.dart';
import 'theme.dart';

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Todo App',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
