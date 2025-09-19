import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/tag_enum.dart';
import '../../data/models/task_model.dart';
import '../../data/services/image_service.dart';
import '../../state/task_store.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task; // null for add, Task object for edit

  const AddEditTaskScreen({
    super.key,
    this.task,
  });

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Tag _selectedTag = Tag.personal;
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  Duration _selectedReminder = const Duration(hours: 1);
  String? _selectedImagePath;

  final ImageService _imageService = ImageService();

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    // If editing, populate form with existing task data
    if (_isEditing) {
      final task = widget.task!;
      _nameController.text = task.name;
      _descriptionController.text = task.description;
      _selectedTag = task.tag;
      _selectedDeadline = task.deadline;
      _selectedReminder = task.notifyBefore;
      _selectedImagePath = task.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Task Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'Enter task name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Task Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tag Selector
            const Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Tag.values.map((tag) {
                return ChoiceChip(
                  label: Text(tag.displayName),
                  selected: _selectedTag == tag,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTag = tag;
                      });
                    }
                  },
                  selectedColor: _getTagColor(tag).withValues(alpha: 0.3),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Deadline Picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Deadline'),
                subtitle: Text(_formatDateTime(_selectedDeadline)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDeadline,
              ),
            ),
            const SizedBox(height: 16),

            // Reminder Picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Remind me before'),
                subtitle: Text(_formatDuration(_selectedReminder)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectReminder,
              ),
            ),
            const SizedBox(height: 16),

            // Image Picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Add Image'),
                subtitle: _selectedImagePath != null
                    ? const Text('Image selected')
                    : const Text('No image selected'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: _pickImageFromCamera,
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_library_outlined),
                      onPressed: _pickImageFromGallery,
                    ),
                  ],
                ),
              ),
            ),
            // Add this to your AddEditTaskScreen for testing
            FloatingActionButton(
              mini: true,
              onPressed: () async {
                final imageService = ImageService();

                // Test gallery permission
                //final hasPermission = await imageService.hasStoragePermission();
                //print('Gallery permission: $hasPermission');

                // Test gallery picker
                final imagePath = await imageService.pickImageFromGallery();
                if (imagePath != null) {
                  //print('Image selected: $imagePath');
                  setState(() {
                    _selectedImagePath = imagePath;
                  });
                } else {
                  //print('No image selected');
                }
              },
              child: const Icon(Icons.bug_report),
            ),

            // Show selected image preview
            if (_selectedImagePath != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Image',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text('Error loading image'),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Text('Image Preview\n(Placeholder)'),
                              ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedImagePath = null;
                          });
                        },
                        child: const Text('Remove Image'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      // Create task object
      final taskData = Task(
        id: _isEditing ? widget.task!.id : null,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        tag: _selectedTag,
        deadline: _selectedDeadline,
        notifyBefore: _selectedReminder,
        imagePath: _selectedImagePath,
        isDone: _isEditing ? widget.task!.isDone : false,
      );

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Save or update task via provider
      final bool success;
      if (_isEditing) {
        success = await ref.read(taskProvider.notifier).updateTask(taskData);
      } else {
        success = await ref.read(taskProvider.notifier).addTask(taskData);
      }

      // Hide loading
      if (mounted) Navigator.of(context).pop();

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'Task updated successfully!'
                  : 'Task created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'Failed to update task. Please try again.'
                  : 'Failed to create task. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectReminder() async {
    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => _ReminderPickerDialog(
        initialReminder: _selectedReminder,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedReminder = result;
      });
    }
  }

  void _pickImageFromCamera() async {
    try {
      final imagePath = await _imageService.pickImageFromCamera();
      if (!mounted) return;

      if (imagePath != null) {
        setState(() {
          _selectedImagePath = imagePath;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image captured successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to capture image'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error accessing camera'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _pickImageFromGallery() async {
    try {
      // First check if we have permission
      if (!await _imageService.hasStoragePermission()) {
        if (mounted) {
          // Show rationale before requesting permission
          final requestPermission = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                  'To add images to your tasks, the app needs access to your photos. '
                  'Would you like to grant permission?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Not Now'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Continue'),
                ),
              ],
            ),
          );

          if (requestPermission != true) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permission is required to select images'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
        }
      }

      final imagePath = await _imageService.pickImageFromGallery();
      if (imagePath != null) {
        setState(() {
          _selectedImagePath = imagePath;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No image selected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error accessing gallery';
        if (e.toString().contains('permission')) {
          errorMessage =
              'Permission denied. Please grant access in Settings to use this feature.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () async {
                await openAppSettings();
              },
            ),
          ),
        );
      }
    }
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'} before';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'} before';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'} before';
    }
  }
}

class _ReminderPickerDialog extends StatelessWidget {
  final Duration initialReminder;

  const _ReminderPickerDialog({required this.initialReminder});

  @override
  Widget build(BuildContext context) {
    final List<Duration> reminderOptions = [
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(hours: 1),
      const Duration(hours: 2),
      const Duration(hours: 6),
      const Duration(hours: 12),
      const Duration(days: 1),
      const Duration(days: 2),
    ];

    return AlertDialog(
      title: const Text('Remind me before'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: reminderOptions.map((duration) {
          return ListTile(
            title: Text(_formatDuration(duration)),
            selected: duration == initialReminder,
            onTap: () {
              Navigator.of(context).pop(duration);
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'} before';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'} before';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'} before';
    }
  }
}
