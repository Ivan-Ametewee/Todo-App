import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_model.dart';
import '../../data/models/tag_enum.dart';
import '../../state/task_store.dart';
import 'add_edit_task_screen.dart';
import '../widgets/task_image_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        elevation: 0,
        actions: [
          // Add carousel button to app bar
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () => _showImageCarousel(context, ref),
            tooltip: 'View All Task Images',
          ),
        ],
      ),
      body: tasks.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: tasks.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskCard(context, ref, task);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first task',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task) {
    return Dismissible(
        key: Key('task_${task.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(height: 4),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          // Show the same confirmation dialog
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Are you sure you want to delete this task?'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This action cannot be undone.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) async {
          // Delete the task
          if (task.id != null) {
            final success =
                await ref.read(taskProvider.notifier).deleteTask(task.id!);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        success ? Icons.check_circle : Icons.error,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(success
                            ? 'Task "${task.name}" deleted'
                            : 'Failed to delete task'),
                      ),
                    ],
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            // Updated leading widget to handle both image and checkbox
            leading: task.imagePath != null && task.imagePath!.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      // Open carousel starting with this task's image
                      final tasksWithImages = ref.read(taskProvider)
                          .where((t) => t.imagePath != null && t.imagePath!.isNotEmpty)
                          .toList();
                      
                      if (tasksWithImages.isNotEmpty) {
                        int initialIndex = tasksWithImages.indexWhere((t) => t.id == task.id);
                        if (initialIndex == -1) initialIndex = 0;
                        
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TaskImageCarousel(
                              tasksWithImages: tasksWithImages,
                              initialIndex: initialIndex,
                            ),
                          ),
                        );
                      }
                    },
                    child: Hero(
                      tag: 'task_image_${task.id}',
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.file(
                            File(task.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () async {
                      // Toggle task completion with loading state
                      if (task.id != null) {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        try {
                          bool success;
                          if (task.isDone) {
                            // Unmark as done
                            final updatedTask = task.copyWith(isDone: false);
                            success = await ref
                                .read(taskProvider.notifier)
                                .updateTask(updatedTask);
                          } else {
                            // Mark as done
                            success = await ref
                                .read(taskProvider.notifier)
                                .markAsDone(task.id!);
                          }

                          if (success) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(task.isDone
                                    ? 'Task marked as incomplete'
                                    : 'Task completed! 🎉'),
                                backgroundColor:
                                    task.isDone ? Colors.orange : Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update task status'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Error updating task status'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isDone ? Colors.green : Colors.transparent,
                        border: Border.all(
                          color: task.isDone ? Colors.green : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: task.isDone
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    task.name,
                    style: TextStyle(
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w500,
                      color: task.isDone ? Colors.grey[600] : null,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(
                      color: task.isDone ? Colors.grey[500] : Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTagColor(task.tag).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getTagColor(task.tag).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        task.tag.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTagColor(task.tag),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Add image indicator if task has image
                    // if (task.imagePath != null && task.imagePath!.isNotEmpty) ...[
                    //   const SizedBox(width: 8),
                    //   Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    //     decoration: BoxDecoration(
                    //       color: Colors.blue.withValues(alpha: 0.1),
                    //       borderRadius: BorderRadius.circular(8),
                    //       border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    //     ),
                    //     child: Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Icon(
                    //           Icons.image_outlined,
                    //           size: 10,
                    //           color: Colors.blue[700],
                    //         ),
                    //         const SizedBox(width: 2),
                    //         Text(
                    //           'Image',
                    //           style: TextStyle(
                    //             fontSize: 10,
                    //             color: Colors.blue[700],
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ],
                    const Spacer(),
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDeadline(task.deadline),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add completion checkbox for tasks with images
                if (task.imagePath != null && task.imagePath!.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      // Toggle completion for image tasks
                      if (task.id != null) {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        try {
                          bool success;
                          if (task.isDone) {
                            final updatedTask = task.copyWith(isDone: false);
                            success = await ref
                                .read(taskProvider.notifier)
                                .updateTask(updatedTask);
                          } else {
                            success = await ref
                                .read(taskProvider.notifier)
                                .markAsDone(task.id!);
                          }

                          if (success) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(task.isDone
                                    ? 'Task marked as incomplete'
                                    : 'Task completed! 🎉'),
                                backgroundColor:
                                    task.isDone ? Colors.orange : Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Error updating task status'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isDone ? Colors.green : Colors.transparent,
                        border: Border.all(
                          color: task.isDone ? Colors.green : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: task.isDone
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            )
                          : null,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: task.isDone ? Colors.grey[400] : Colors.grey[600],
                  ),
                  onPressed: () async {
                // Show confirmation dialog for delete
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            'Are you sure you want to delete this task?'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (task.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  task.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This action cannot be undone.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true && task.id != null) {
                  final currentContext = context;

                  if (currentContext.mounted) {
                    // Show loading while deleting
                    showDialog(
                      context: currentContext,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  try {
                    final success = await ref
                        .read(taskProvider.notifier)
                        .deleteTask(task.id!);

                    // Hide loading dialog
                    if (context.mounted) Navigator.of(context).pop();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                success ? Icons.check_circle : Icons.error,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(success
                                    ? 'Task "${task.name}" deleted successfully'
                                    : 'Failed to delete task. Please try again.'),
                              ),
                            ],
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    // Hide loading dialog
                    if (context.mounted) Navigator.of(context).pop();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                    'An error occurred while deleting the task'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                }
              },
            ),
              ],
            ),
            onTap: () {
              // Navigate to edit task screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditTaskScreen(task: task),
                ),
              );
            },
          ),
        ));
  }

  Color _getTagColor(Tag tag) {
    switch (tag) {
      case Tag.business:
        return Colors.blue;
      case Tag.work:
        return Colors.purple;
      case Tag.school:
        return Colors.green;
      case Tag.personal:
        return Colors.orange;
      case Tag.other:
        return Colors.grey;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else {
      return '${difference.inMinutes}m left';
    }
  }
  void _showImageCarousel(BuildContext context, WidgetRef ref) {
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskImageCarousel(
          tasksWithImages: tasksWithImages,
          initialIndex: 0,
        ),
      ),
    );
  }
}

