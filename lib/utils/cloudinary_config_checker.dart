import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A utility class to check and validate Cloudinary configuration
class CloudinaryConfigChecker {
  /// Check if the Cloudinary configuration is valid
  static bool checkConfig() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
    final apiKey = dotenv.env['CLOUDINARY_API_KEY'];
    final apiSecret = dotenv.env['CLOUDINARY_API_SECRET'];

    debugPrint('\n=== Cloudinary Configuration Check ===');
    debugPrint('Cloud Name: ${cloudName ?? "MISSING"}');
    debugPrint('Upload Preset: ${uploadPreset ?? "MISSING"}');
    debugPrint('API Key: ${apiKey != null ? "CONFIGURED" : "MISSING"}');
    debugPrint('API Secret: ${apiSecret != null ? "CONFIGURED" : "MISSING"}');

    // Check if minimal configuration is present
    final isValid =
        cloudName != null &&
        cloudName.isNotEmpty &&
        uploadPreset != null &&
        uploadPreset.isNotEmpty;

    debugPrint('Basic configuration valid: $isValid');
    debugPrint('======================================\n');

    return isValid;
  }
}
