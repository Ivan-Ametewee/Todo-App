import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/services/image_service.dart';

class TaskImageWidget extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool showErrorIcon;

  const TaskImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showErrorIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    final imageService = ImageService();
    if (!imageService.isValidImagePath(imagePath)) {
      return showErrorIcon ? _buildErrorWidget() : _buildPlaceholder();
    }

    final imageWidget = Image.file(
      File(imagePath!),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return showErrorIcon ? _buildErrorWidget() : _buildPlaceholder();
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }
}

// Convenience widget for task list items (small thumbnail)
class TaskThumbnailWidget extends StatelessWidget {
  final String? imagePath;

  const TaskThumbnailWidget({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return TaskImageWidget(
      imagePath: imagePath,
      width: 60,
      height: 60,
      borderRadius: BorderRadius.circular(8),
      showErrorIcon: false,
    );
  }
}

// Convenience widget for task detail view (larger display)
class TaskDetailImageWidget extends StatelessWidget {
  final String? imagePath;

  const TaskDetailImageWidget({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return const SizedBox.shrink();
    }

    return TaskImageWidget(
      imagePath: imagePath,
      width: double.infinity,
      height: 200,
      borderRadius: BorderRadius.circular(12),
    );
  }
}