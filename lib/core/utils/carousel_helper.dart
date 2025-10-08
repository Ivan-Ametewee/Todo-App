import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/widgets/task_image_carousel.dart';
import '../../data/models/task_model.dart';
import '../../state/task_store.dart';

class CarouselHelper {
  static void showTaskImageCarousel(
    BuildContext context, 
    WidgetRef ref, {
    Task? selectedTask,
  }) {
    // Get all tasks with images
    final allTasks = ref.read(taskProvider);
    final tasksWithImages = allTasks
        .where((task) => task.imagePath != null && task.imagePath!.isNotEmpty)
        .toList();

    if (tasksWithImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No task images to display'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Find the initial index if a specific task is selected
    int initialIndex = 0;
    if (selectedTask != null) {
      initialIndex = tasksWithImages.indexWhere((task) => task.id == selectedTask.id);
      if (initialIndex == -1) initialIndex = 0;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskImageCarousel(
          tasksWithImages: tasksWithImages,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// Extension method for easy access
extension TaskImageCarouselExtension on BuildContext {
  void showTaskImages(WidgetRef ref, {Task? selectedTask}) {
    CarouselHelper.showTaskImageCarousel(this, ref, selectedTask: selectedTask);
  }
}