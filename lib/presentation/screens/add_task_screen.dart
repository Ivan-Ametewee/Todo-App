// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../data/models/tag_enum.dart';
// import '../../data/models/task_model.dart';
// import '../../state/task_store.dart';

// class AddTaskScreen extends ConsumerStatefulWidget {
//   const AddTaskScreen({super.key, this.taskToEdit});

//   final Task? taskToEdit;

//   @override
//   ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
// }

// class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();

//   Tag _selectedTag = Tag.personal;
//   late DateTime _selectedDate;
//   late TimeOfDay _selectedTime;
//   Duration _selectedNotifyBefore = const Duration(hours: 1);

//   @override
//   void initState() {
//     super.initState();
//     if (widget.taskToEdit != null) {
//       // Initialize form with existing task data
//       final task = widget.taskToEdit!;
//       _nameController.text = task.name;
//       _descriptionController.text = task.description;
//       _selectedTag = task.tag;
//       _selectedDate = task.deadline;
//       _selectedTime = TimeOfDay.fromDateTime(task.deadline);
//       _selectedNotifyBefore = task.notifyBefore;
//     } else {
//       // Initialize with defaults for new task
//       _selectedDate = DateTime.now();
//       _selectedTime = TimeOfDay.now();
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.taskToEdit == null ? 'Add Task' : 'Edit Task'),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               if (_formKey.currentState?.validate() ?? false) {
//                 // Create deadline DateTime by combining date and time
//                 final deadline = DateTime(
//                   _selectedDate.year,
//                   _selectedDate.month,
//                   _selectedDate.day,
//                   _selectedTime.hour,
//                   _selectedTime.minute,
//                 );

//                 final task = Task(
//                   id: widget.taskToEdit?.id, // Keep existing ID if editing
//                   name: _nameController.text,
//                   description: _descriptionController.text,
//                   tag: _selectedTag,
//                   deadline: deadline,
//                   notifyBefore: _selectedNotifyBefore,
//                   isDone: widget.taskToEdit?.isDone ??
//                       false, // Keep done state if editing
//                 );

//                 final success = widget.taskToEdit == null
//                     ? await ref.read(taskProvider.notifier).addTask(task)
//                     : await ref.read(taskProvider.notifier).updateTask(task);

//                 if (success && mounted) {
//                   Navigator.of(context).pop();
//                 } else if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         widget.taskToEdit == null
//                             ? 'Failed to create task. Please try again.'
//                             : 'Failed to update task. Please try again.',
//                       ),
//                     ),
//                   );
//                 }
//               }
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             TextFormField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Task Name',
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter a task name';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(
//                 labelText: 'Description',
//                 border: OutlineInputBorder(),
//                 alignLabelWithHint: true,
//               ),
//               maxLines: 3,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter a description';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<Tag>(
//               initialValue: _selectedTag,
//               decoration: const InputDecoration(
//                 labelText: 'Tag',
//                 border: OutlineInputBorder(),
//               ),
//               items: Tag.values.map((tag) {
//                 return DropdownMenuItem(
//                   value: tag,
//                   child: Text(tag.toString()),
//                 );
//               }).toList(),
//               onChanged: (Tag? value) {
//                 if (value != null) {
//                   setState(() {
//                     _selectedTag = value;
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 16),
//             InkWell(
//               onTap: () async {
//                 final date = await showDatePicker(
//                   context: context,
//                   initialDate: _selectedDate,
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime.now().add(const Duration(days: 365)),
//                 );
//                 if (date != null) {
//                   setState(() {
//                     _selectedDate = date;
//                   });
//                 }
//               },
//               child: InputDecorator(
//                 decoration: const InputDecoration(
//                   labelText: 'Deadline Date',
//                   border: OutlineInputBorder(),
//                 ),
//                 child: Text(
//                   '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             InkWell(
//               onTap: () async {
//                 final time = await showTimePicker(
//                   context: context,
//                   initialTime: _selectedTime,
//                 );
//                 if (time != null) {
//                   setState(() {
//                     _selectedTime = time;
//                   });
//                 }
//               },
//               child: InputDecorator(
//                 decoration: const InputDecoration(
//                   labelText: 'Deadline Time',
//                   border: OutlineInputBorder(),
//                 ),
//                 child: Text(
//                   '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<Duration>(
//               value: _selectedNotifyBefore,
//               decoration: const InputDecoration(
//                 labelText: 'Remind me before',
//                 border: OutlineInputBorder(),
//               ),
//               items: const [
//                 DropdownMenuItem(
//                   value: Duration(minutes: 15),
//                   child: Text('15 minutes before'),
//                 ),
//                 DropdownMenuItem(
//                   value: Duration(minutes: 30),
//                   child: Text('30 minutes before'),
//                 ),
//                 DropdownMenuItem(
//                   value: Duration(hours: 1),
//                   child: Text('1 hour before'),
//                 ),
//                 DropdownMenuItem(
//                   value: Duration(hours: 2),
//                   child: Text('2 hours before'),
//                 ),
//                 DropdownMenuItem(
//                   value: Duration(days: 1),
//                   child: Text('1 day before'),
//                 ),
//               ],
//               onChanged: (Duration? value) {
//                 if (value != null) {
//                   setState(() {
//                     _selectedNotifyBefore = value;
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 16),
//             OutlinedButton.icon(
//               onPressed: () {
//                 // Will implement image picking later
//               },
//               icon: const Icon(Icons.photo_camera),
//               label: const Text('Add Image'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
