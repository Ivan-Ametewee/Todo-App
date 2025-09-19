import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  static final ImagePicker _picker = ImagePicker();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  ImageService._internal();

  factory ImageService() => _instance;

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        final status = await Permission.photos.status;
        return status.isGranted || status.isLimited;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return true; // iOS handles permissions through picker
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        final status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // iOS handles permissions through picker
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<String?> pickImageFromGallery() async {
    try {
      // Check current permission status
      if (!await hasStoragePermission()) {
        final hasPermission = await _requestStoragePermission();
        if (!hasPermission) {
          throw 'Storage permission denied';
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImage(image);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<String?> pickImageFromCamera() async {
    try {
      // Check and request camera permission
      if (!await _requestCameraPermission()) {
        throw 'Camera permission denied';
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImage(image);
      }
      return null;
    } catch (e) {
      print('Error taking image from camera: $e');
      rethrow;
    }
  }

  Future<String?> pickImage({ImageSource? source}) async {
    try {
      if (source != null) {
        return source == ImageSource.camera
            ? await pickImageFromCamera()
            : await pickImageFromGallery();
      }
      return await pickImageFromGallery();
    } catch (e) {
      print('Error picking image: $e');
      rethrow;
    }
  }

  Future<String> _saveImage(XFile image) async {
    try {
      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'images');

      // Create images directory if it doesn't exist
      await Directory(imagesDir).create(recursive: true);

      // Generate unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(image.path);
      final String fileName = 'task_image_$timestamp$extension';
      final String savedPath = path.join(imagesDir, fileName);

      // Copy image to app directory
      final File imageFile = File(image.path);
      await imageFile.copy(savedPath);

      return savedPath;
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  bool isValidImagePath(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return false;
    final File imageFile = File(imagePath);
    return imageFile.existsSync();
  }
}
