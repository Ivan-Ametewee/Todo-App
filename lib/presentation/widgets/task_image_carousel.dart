import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';

class TaskImageCarousel extends StatefulWidget {
  final List<Task> tasksWithImages;
  final int initialIndex;

  const TaskImageCarousel({
    super.key,
    required this.tasksWithImages,
    this.initialIndex = 0,
  });

  @override
  State<TaskImageCarousel> createState() => _TaskImageCarouselState();
}

class _TaskImageCarouselState extends State<TaskImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasksWithImages.isEmpty) {
      return const Center(
        child: Text('No images to display'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Task Images (${_currentIndex + 1}/${widget.tasksWithImages.length})',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Main carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.tasksWithImages.length,
              itemBuilder: (context, index) {
                final task = widget.tasksWithImages[index];
                return _buildImagePage(task);
              },
            ),
          ),
          
          // Task name and info section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: _buildTaskInfo(widget.tasksWithImages[_currentIndex]),
          ),
          
          // Thumbnail row
          if (widget.tasksWithImages.length > 1)
            Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.tasksWithImages.length,
                itemBuilder: (context, index) {
                  return _buildThumbnail(index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePage(Task task) {
    return Center(
      child: Hero(
        tag: 'task_image_${task.id}',
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: task.imagePath != null && File(task.imagePath!).existsSync()
                  ? Image.file(
                      File(task.imagePath!),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorWidget();
                      },
                    )
                  : _buildErrorWidget(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfo(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Task name
        Text(
          task.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Task description
        if (task.description.isNotEmpty)
          Text(
            task.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        
        const SizedBox(height: 12),
        
        // Task details row
        Row(
          children: [
            // Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTagColor(task.tag).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getTagColor(task.tag),
                  width: 1,
                ),
              ),
              child: Text(
                task.tag.displayName,
                style: TextStyle(
                  color: _getTagColor(task.tag),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: task.isDone ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: task.isDone ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Text(
                task.isDone ? 'Completed' : 'Pending',
                style: TextStyle(
                  color: task.isDone ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const Spacer(),
            
            // Deadline
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Due Date',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
                Text(
                  _formatDate(task.deadline),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThumbnail(int index) {
    final task = widget.tasksWithImages[index];
    final isSelected = index == _currentIndex;
    
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: task.imagePath != null && File(task.imagePath!).existsSync()
              ? Image.file(
                  File(task.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildThumbnailError();
                  },
                )
              : _buildThumbnailError(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[800],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.white54,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Image not found',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailError() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 24,
      ),
    );
  }

  Color _getTagColor(tag) {
    // You can customize these colors based on your tag enum
    switch (tag.toString().toLowerCase()) {
      case 'business':
        return Colors.blue;
      case 'work':
        return Colors.purple;
      case 'school':
        return Colors.green;
      case 'personal':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}