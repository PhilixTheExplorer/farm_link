import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Custom class for handling images across platforms
class PickedImage {
  final XFile xFile;
  final String? webPath;
  final File? fileData; // Store the file for non-web platforms

  PickedImage({required this.xFile, this.webPath})
    : fileData = kIsWeb ? null : File(xFile.path);

  /// Check if the image exists
  Future<bool> exists() async {
    if (kIsWeb) {
      return webPath != null;
    } else {
      return await File(xFile.path).exists();
    }
  }

  /// Get the image path
  String get path => xFile.path;

  /// Get as a file (only for non-web platforms)
  File? get file => fileData;

  /// Get the web-specific path (only for web)
  String? get webImagePath => webPath;

  /// Convert to File (for compatibility with existing code)
  File? toFile() {
    if (kIsWeb) {
      return null; // Web doesn't support true File objects
    } else {
      return File(xFile.path);
    }
  }
}

/// Service for handling image uploads to Cloudinary
class ImageUploadService {
  // Cloudinary configuration - add these to your .env file
  static final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String _uploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static final String _apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static final String _apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick image from gallery
  Future<PickedImage?> pickImageFromGallery({
    int maxWidth = 800,
    int maxHeight = 800,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image == null) return null;

      if (kIsWeb) {
        return PickedImage(xFile: image, webPath: image.path);
      } else {
        return PickedImage(xFile: image);
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      throw Exception('Failed to pick image from gallery: ${e.toString()}');
    }
  }

  /// Pick image from camera
  Future<PickedImage?> pickImageFromCamera({
    int maxWidth = 800,
    int maxHeight = 800,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image == null) return null;

      if (kIsWeb) {
        return PickedImage(xFile: image, webPath: image.path);
      } else {
        return PickedImage(xFile: image);
      }
    } catch (e) {
      debugPrint('Error taking photo from camera: $e');
      throw Exception('Failed to take photo from camera: ${e.toString()}');
    }
  }

  /// Upload image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadToCloudinary(
    PickedImage pickedImage, {
    String? folder,
    Map<String, dynamic>? transformations,
  }) async {
    try {
      if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
        throw Exception(
          'Cloudinary configuration missing. Please add CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET to your .env file',
        );
      }

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);

      // Add the image file depending on platform
      if (kIsWeb) {
        // For web, we need to read the file as bytes and use the name
        final bytes = await pickedImage.xFile.readAsBytes();
        final filename = pickedImage.xFile.name;
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: filename),
        );
      } else {
        // For mobile, we can use the standard fromPath
        request.files.add(
          await http.MultipartFile.fromPath('file', pickedImage.xFile.path),
        );
      }

      // Add upload preset
      request.fields['upload_preset'] = _uploadPreset;

      // Add folder if specified
      if (folder != null) {
        request.fields['folder'] = folder;
      }

      // Add transformations if specified
      if (transformations != null) {
        request.fields['transformation'] = json.encode(transformations);
      }

      // Add timestamp and signature for secured uploads (optional)
      if (_apiKey.isNotEmpty && _apiSecret.isNotEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        request.fields['timestamp'] = timestamp.toString();
        request.fields['api_key'] = _apiKey;

        // Generate signature (you would need to implement this based on Cloudinary's signature algorithm)
        // For now, we'll use the upload preset which doesn't require signature
      }

      debugPrint('Uploading image to Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        final secureUrl = data['secure_url'] as String?;

        if (secureUrl != null) {
          debugPrint('Image uploaded successfully: $secureUrl');
          return secureUrl;
        } else {
          throw Exception('No secure URL returned from Cloudinary');
        }
      } else {
        debugPrint('Cloudinary upload failed: ${response.statusCode}');
        debugPrint('Response: $responseData');
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Pick and upload image from gallery
  Future<String?> pickAndUploadFromGallery({
    String? folder,
    Map<String, dynamic>? transformations,
    int maxWidth = 800,
    int maxHeight = 800,
    int imageQuality = 80,
  }) async {
    final imageFile = await pickImageFromGallery(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );

    if (imageFile != null) {
      return await uploadToCloudinary(
        imageFile,
        folder: folder,
        transformations: transformations,
      );
    }

    return null;
  }

  /// Pick and upload image from camera
  Future<String?> pickAndUploadFromCamera({
    String? folder,
    Map<String, dynamic>? transformations,
    int maxWidth = 800,
    int maxHeight = 800,
    int imageQuality = 80,
  }) async {
    final imageFile = await pickImageFromCamera(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );

    if (imageFile != null) {
      return await uploadToCloudinary(
        imageFile,
        folder: folder,
        transformations: transformations,
      );
    }

    return null;
  }

  /// Delete image from Cloudinary
  /// Requires the public ID of the image
  Future<bool> deleteFromCloudinary(String publicId) async {
    try {
      if (_apiKey.isEmpty || _apiSecret.isEmpty) {
        throw Exception(
          'Cloudinary API credentials missing. Please add CLOUDINARY_API_KEY and CLOUDINARY_API_SECRET to your .env file',
        );
      }

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy',
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Generate signature for deletion (simplified - you may need to implement proper signature generation)
      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': _apiKey,
          // 'signature': signature, // Would need proper signature generation
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] == 'ok';
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting from Cloudinary: $e');
      return false;
    }
  }

  /// Get optimized image URL with transformations
  static String getOptimizedImageUrl(
    String imageUrl, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    if (!imageUrl.contains('cloudinary.com')) {
      // Return original URL if it's not a Cloudinary URL
      return imageUrl;
    }

    final transformations = <String>[];

    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_$format');

    final transformationString = transformations.join(',');

    // Insert transformations into the Cloudinary URL
    return imageUrl.replaceFirst(
      '/image/upload/',
      '/image/upload/$transformationString/',
    );
  }
}
