import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

/// File picker result with cross-platform support
class PickedFileResult {
  final String? path;
  final Uint8List? bytes;
  final String? name;
  final String? mimeType;

  PickedFileResult({
    this.path,
    this.bytes,
    this.name,
    this.mimeType,
  });

  bool get isValid => (path != null && path!.isNotEmpty) || (bytes != null && bytes!.isNotEmpty);
}

/// Service for picking files with web and mobile support
class FilePickerService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from camera or gallery
  /// For web, use file_picker with image type
  static Future<PickedFileResult?> pickImage({
    bool fromCamera = false,
    int imageQuality = 80,
  }) async {
    try {
      if (kIsWeb) {
        // On web, use file_picker for images
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );

        if (result == null || result.files.isEmpty) return null;

        final file = result.files.first;
        return PickedFileResult(
          bytes: file.bytes,
          name: file.name,
          mimeType: _getMimeType(file.extension),
        );
      } else {
        // On mobile, use image_picker
        final ImageSource source = fromCamera 
            ? ImageSource.camera 
            : ImageSource.gallery;

        final XFile? pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: imageQuality,
        );

        if (pickedFile == null) return null;

        return PickedFileResult(
          path: pickedFile.path,
          name: pickedFile.name,
          mimeType: pickedFile.mimeType,
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick a file (PDF, images, etc.)
  static Future<PickedFileResult?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        withData: kIsWeb, // Load bytes on web
        withReadStream: !kIsWeb, // Use stream on mobile
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;

      if (kIsWeb) {
        // On web, use bytes
        return PickedFileResult(
          bytes: file.bytes,
          name: file.name,
          mimeType: _getMimeType(file.extension),
        );
      } else {
        // On mobile, use path
        return PickedFileResult(
          path: file.path,
          name: file.name,
          mimeType: _getMimeType(file.extension),
        );
      }
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  /// Pick multiple files
  static Future<List<PickedFileResult>> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        withData: kIsWeb,
        withReadStream: !kIsWeb,
      );

      if (result == null || result.files.isEmpty) return [];

      return result.files.map((file) {
        if (kIsWeb) {
          return PickedFileResult(
            bytes: file.bytes,
            name: file.name,
            mimeType: _getMimeType(file.extension),
          );
        } else {
          return PickedFileResult(
            path: file.path,
            name: file.name,
            mimeType: _getMimeType(file.extension),
          );
        }
      }).toList();
    } catch (e) {
      print('Error picking multiple files: $e');
      return [];
    }
  }

  static String? _getMimeType(String? extension) {
    if (extension == null) return null;
    
    final ext = extension.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}
