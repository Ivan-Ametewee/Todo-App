import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../app/theme.dart';
import 'task_image_widget.dart';

class EnhancedTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleDone;
  final VoidCallback? onDelete;

  const EnhancedTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleDone,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = task.deadline.isBefore(DateTime.now()) && !task.isDone;
    final tagColor = AppTheme.getTagColor(task.tag.name);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Task completion checkbox
                  GestureDetector(
                    onTap: onToggleDone,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isDone
                              ? theme.primaryColor
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: task.isDone
                            ? theme.primaryColor
                            : Colors.transparent,
                      ),
                      child: task.isDone
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Task name
                  Expanded(
                    child: Text(
                      task.name,
                      style: AppTheme.titleStyle.copyWith(
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? Colors.grey[600] : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Tag chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: tagColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      task.tag.displayName,
                      style: AppTheme.captionStyle.copyWith(
                        color: tagColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Description
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: AppTheme.bodyStyle.copyWith(
                    color: task.isDone ? Colors.grey[600] : Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Bottom row with image, deadline, and actions
              Row(
                children: [
                  // Task image thumbnail
                  if (task.imagePath != null) ...[
                    TaskThumbnailWidget(imagePath: task.imagePath),
                    const SizedBox(width: 12),
                  ],

                  // Deadline info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 16,
                              color: isOverdue
                                  ? AppTheme.errorColor
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDeadline(),
                              style: AppTheme.captionStyle.copyWith(
                                color: isOverdue
                                    ? AppTheme.errorColor
                                    : Colors.grey[600],
                                fontWeight: isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        if (task.notifyBefore.inMinutes > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatReminder(),
                                style: AppTheme.captionStyle,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Delete button
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.grey[600],
                      iconSize: 20,
                    ),
                ],
              ),

              // Overdue indicator
              if (isOverdue) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppTheme.errorColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'OVERDUE',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDeadline() {
    final now = DateTime.now();
    final difference = task.deadline.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} left';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} left';
    }
  }

  String _formatReminder() {
    if (task.notifyBefore.inDays > 0) {
      return '${task.notifyBefore.inDays}d before';
    } else if (task.notifyBefore.inHours > 0) {
      return '${task.notifyBefore.inHours}h before';
    } else {
      return '${task.notifyBefore.inMinutes}m before';
    }
  }
}
