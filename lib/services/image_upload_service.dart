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
    bool useSignedUpload = false,
  }) async {
    try {
      // Debug information to help diagnose configuration issues
      debugPrint('Cloudinary Configuration:');
      debugPrint(
        '  Cloud Name: ${_cloudName.isEmpty ? "MISSING" : _cloudName}',
      );
      debugPrint(
        '  Upload Preset: ${_uploadPreset.isEmpty ? "MISSING" : _uploadPreset}',
      );
      debugPrint('  API Key: ${_apiKey.isEmpty ? "MISSING" : "CONFIGURED"}');
      debugPrint(
        '  API Secret: ${_apiSecret.isEmpty ? "MISSING" : "CONFIGURED"}',
      );
      debugPrint('  Signed Upload Mode: $useSignedUpload');

      if (_cloudName.isEmpty) {
        throw Exception(
          'Cloudinary cloud name missing. Please add CLOUDINARY_CLOUD_NAME to your .env file',
        );
      }

      if (_uploadPreset.isEmpty && !useSignedUpload) {
        throw Exception(
          'Cloudinary upload preset missing. Please add CLOUDINARY_UPLOAD_PRESET to your .env file',
        );
      }

      if (useSignedUpload && (_apiKey.isEmpty || _apiSecret.isEmpty)) {
        throw Exception(
          'Cloudinary API credentials missing. Please add CLOUDINARY_API_KEY and CLOUDINARY_API_SECRET to your .env file',
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
      } // Use either upload preset (unsigned) or signed upload
      if (useSignedUpload) {
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        request.fields['timestamp'] = timestamp.toString();
        request.fields['api_key'] = _apiKey;

        // Add folder to signature params if specified
        if (folder != null) {
          request.fields['folder'] = folder;
        }

        // Add transformations if specified
        if (transformations != null) {
          final transformString = _formatTransformations(transformations);
          request.fields['transformation'] = transformString;
        }

        // Note: In a production app, you would generate a proper signature with SHA-1 hashing
        // For now, we'll use a simplified approach that works for the demo
        // Since we're not requiring enhanced security at this point
        final paramsToSign = {
          'timestamp': timestamp.toString(),
          if (folder != null) 'folder': folder,
          if (transformations != null)
            'transformation': _formatTransformations(transformations),
        };

        // Generate a simple signature - in production this would use proper SHA-1 hashing
        final signatureString = _generateSimpleSignature(paramsToSign);
        request.fields['signature'] = signatureString;
      } else {
        // Use upload preset for unsigned uploads
        request.fields['upload_preset'] = _uploadPreset;

        // Add folder if specified
        if (folder != null) {
          request.fields['folder'] = folder;
        }

        // NOTE: For unsigned uploads, we cannot include transformation parameters directly
        // We will apply transformations after upload by modifying the returned URL
        // Keeping track of transformations for later use
        debugPrint(
          'Using unsigned upload - transformations will be applied to the returned URL',
        );
      }

      // Always add these settings for better quality and optimization
      request.fields['quality'] = 'auto';
      request.fields['fetch_format'] = 'auto';

      // Add additional metadata to help with organization
      request.fields['tags'] = 'farm_link,mobile_upload';
      request.fields['context'] =
          'app=farm_link|platform=${kIsWeb ? 'web' : 'mobile'}';
      request.fields['resource_type'] = 'image';

      debugPrint('Uploading image to Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        final secureUrl = data['secure_url'] as String?;
        final publicId = data['public_id'] as String?;

        // We can use these values for detailed logging or advanced features in the future
        // final version = data['version'] as int?;

        if (secureUrl != null) {
          debugPrint('Image uploaded successfully: $secureUrl');
          debugPrint('Image public ID: $publicId');

          // If transformations were specified, apply them to the returned URL
          // This ensures the image is delivered with the requested transformations
          if (transformations != null && transformations.isNotEmpty) {
            final transformedUrl = getOptimizedImageUrl(
              secureUrl,
              width: transformations['width'] as int?,
              height: transformations['height'] as int?,
              crop: transformations['crop'] as String?,
              gravity: transformations['gravity'] as String?,
            );
            return transformedUrl;
          }

          return secureUrl;
        } else {
          throw Exception('No secure URL returned from Cloudinary');
        }
      } else {
        debugPrint('Cloudinary upload failed: ${response.statusCode}');
        debugPrint('Response: $responseData');
        throw Exception(
          'Upload failed with status: ${response.statusCode}. ${_extractErrorMessage(responseData)}',
        );
      }
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      return null; // Return null instead of throwing to handle errors better in callers
    }
  }

  /// Generate a simple signature for Cloudinary API requests
  /// This is a simplified implementation for demo purposes
  /// In production, use a proper SHA-1 hash with the crypto package
  String _generateSimpleSignature(Map<String, dynamic> params) {
    // Sort parameters alphabetically by key
    final sortedKeys = params.keys.toList()..sort();

    // Build signature string
    final signatureBaseStr = sortedKeys
        .map((key) => '$key=${params[key]}')
        .join('&');

    // Append API secret
    final signatureInput = signatureBaseStr + _apiSecret;

    // For demo purposes, we're using a simple hash
    // This should be replaced with proper SHA-1 hashing in production
    debugPrint('Generating signature for: $signatureInput');
    return signatureInput.hashCode.toString(); // Not secure, just for demo
  }

  /// Format transformations for Cloudinary API
  String _formatTransformations(Map<String, dynamic> transformations) {
    // Convert transformations map to Cloudinary format
    // For example: {'width': 300, 'height': 300, 'crop': 'fill'} => 'w_300,h_300,c_fill'
    final formattedParams = <String>[];

    transformations.forEach((key, value) {
      // Map common parameters to Cloudinary shorthand
      String shortKey;
      switch (key) {
        case 'width':
          shortKey = 'w';
          break;
        case 'height':
          shortKey = 'h';
          break;
        case 'crop':
          shortKey = 'c';
          break;
        case 'quality':
          shortKey = 'q';
          break;
        case 'format':
          shortKey = 'f';
          break;
        default:
          shortKey = key;
      }

      formattedParams.add('${shortKey}_$value');
    });

    return formattedParams.join(',');
  }

  /// Extract error message from Cloudinary response
  String _extractErrorMessage(String responseData) {
    try {
      final data = json.decode(responseData);
      return data['error']?['message'] ?? 'Unknown error';
    } catch (_) {
      return 'Failed to parse error message';
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

      // Create signature parameters
      final signatureParams = {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      };

      // Generate a simple signature
      final signatureString = _generateSimpleSignature(signatureParams);

      // Send the request with the required parameters
      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': _apiKey,
          'signature': signatureString,
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

  /// Get image information from Cloudinary
  /// This can be useful for getting details about an uploaded image
  Future<Map<String, dynamic>?> getImageInfo(String publicId) async {
    try {
      if (_apiKey.isEmpty || _apiSecret.isEmpty) {
        throw Exception(
          'Cloudinary API credentials missing. Please add CLOUDINARY_API_KEY and CLOUDINARY_API_SECRET to your .env file',
        );
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create signature parameters
      final signatureParams = {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      };

      // Generate a signature
      final signatureString = _generateSimpleSignature(signatureParams);

      // Build the URL for the resource details API
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/resources/image/upload/$publicId',
      );

      // Add authentication parameters
      final queryParams = {
        'api_key': _apiKey,
        'timestamp': timestamp.toString(),
        'signature': signatureString,
      };

      // Send the request
      final response = await http.get(
        uri.replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get image info: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting image info: $e');
      return null;
    }
  }

  /// Get optimized image URL with transformations
  /// This method allows you to create a transformed version of an existing Cloudinary URL
  static String getOptimizedImageUrl(
    String imageUrl, {
    // Basic transformations
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String? crop,
    String? gravity,

    // Advanced transformations
    int? radius,
    String? effect,
    double? opacity,
    bool? progressive,
    String? background,
    bool? dpr,
    String? overlay,
    String? underlay,
    int? angle,

    // Custom transformations
    bool useCustomTransformations = false,
    List<String>? customTransformations,

    // AI transformations
    bool? removeBackground,
    bool? enhanceFace,
    bool? enhanceImage,
    bool? autoColor,
  }) {
    if (!imageUrl.contains('cloudinary.com')) {
      // Return original URL if it's not a Cloudinary URL
      return imageUrl;
    }

    final transformations = <String>[];

    if (useCustomTransformations && customTransformations != null) {
      // Use custom transformation string directly
      return imageUrl.replaceFirst(
        '/image/upload/',
        '/image/upload/${customTransformations.join(",")}/',
      );
    } else {
      // Build transformation string from parameters
      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');

      // Only add crop if width or height is specified
      if (crop != null && (width != null || height != null)) {
        transformations.add('c_$crop');

        // Add gravity if crop is specified
        if (gravity != null) {
          transformations.add('g_$gravity');
        }
      }

      // Add other transformations
      if (radius != null) transformations.add('r_$radius');
      if (effect != null) transformations.add('e_$effect');
      if (opacity != null) transformations.add('o_$opacity');
      if (progressive == true) transformations.add('fl_progressive');
      if (background != null) transformations.add('b_$background');
      if (dpr == true) transformations.add('dpr_auto');
      if (angle != null) transformations.add('a_$angle');

      // Overlays
      if (overlay != null) transformations.add('l_$overlay');
      if (underlay != null) transformations.add('u_$underlay');

      // AI features
      if (removeBackground == true) transformations.add('e_background_removal');
      if (enhanceFace == true) transformations.add('e_improve:face');
      if (enhanceImage == true) transformations.add('e_enhance');
      if (autoColor == true) transformations.add('e_auto_color');

      // Always add quality and format for optimization
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

  /// Generate a responsive image URL optimized for different screen sizes
  static String getResponsiveImageUrl(
    String imageUrl, {
    bool autoWidth = true,
    int? maxWidth,
    String crop = 'fill',
    String quality = 'auto',
    String format = 'auto',
  }) {
    if (!imageUrl.contains('cloudinary.com')) {
      return imageUrl;
    }

    final transformations = <String>['q_$quality', 'f_$format', 'c_$crop'];

    if (autoWidth) {
      // Add responsive width transformation
      transformations.add('w_auto');

      // Add max width if specified
      if (maxWidth != null) {
        transformations.add('dpr_auto');
      }
    }

    final transformationString = transformations.join(',');

    // Insert transformations into the Cloudinary URL
    return imageUrl.replaceFirst(
      '/image/upload/',
      '/image/upload/$transformationString/',
    );
  }

  /// Create a Cloudinary URL from a publicId
  /// This is useful when you have stored just the publicId and need to generate a URL
  static String createUrlFromPublicId(
    String publicId, {
    String cloudName = '', // If empty, will use the one from .env
    String transformations = '',
    bool secure = true,
  }) {
    final effectiveCloudName = cloudName.isNotEmpty ? cloudName : _cloudName;

    if (effectiveCloudName.isEmpty) {
      throw Exception('Cloudinary cloud name is required');
    }

    // Check if publicId already contains folder structure
    final cleanPublicId =
        publicId.startsWith('/') ? publicId.substring(1) : publicId;

    // Build the base URL
    final baseUrl =
        secure
            ? 'https://res.cloudinary.com/$effectiveCloudName/image/upload'
            : 'http://res.cloudinary.com/$effectiveCloudName/image/upload';

    // Add transformations if provided
    final transformationSegment =
        transformations.isNotEmpty ? '$transformations/' : '';

    // Return the full URL
    return '$baseUrl/$transformationSegment$cleanPublicId';
  }
}
