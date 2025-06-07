import 'package:flutter/material.dart';
import '../services/image_upload_service.dart';

/// A utility class to test Cloudinary uploads
class CloudinaryTester extends StatelessWidget {
  final ImageUploadService _imageUploadService = ImageUploadService();

  CloudinaryTester({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloudinary Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              child: const Text('Test Image Upload'),
            ),
            const SizedBox(height: 20),
            const Text('Check console for upload results'),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final result = await _imageUploadService.pickAndUploadFromGallery(
        folder: 'test_uploads',
        transformations: {'width': 300, 'height': 300, 'crop': 'fill'},
      );

      debugPrint('Upload result: $result');

      if (result != null) {
        debugPrint('Upload successful! URL: $result');
      } else {
        debugPrint('Upload failed or was cancelled');
      }
    } catch (e) {
      debugPrint('Error during test upload: $e');
    }
  }
}
