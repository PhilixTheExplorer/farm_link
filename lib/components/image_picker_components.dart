import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_colors.dart';
import '../services/image_upload_service.dart';

/// Reusable image picker modal bottom sheet
class ImagePickerModal {
  /// Show image picker modal with gallery and camera options
  static Future<ImageSource?> show(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _ImagePickerModalContent(),
    );
  }
}

class _ImagePickerModalContent extends StatelessWidget {
  const _ImagePickerModalContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Select Image Source',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Options
            Row(
              children: [
                // Gallery option
                Expanded(
                  child: _ImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 16),

                // Camera option
                Expanded(
                  child: _ImageSourceOption(
                    icon: Icons.photo_camera,
                    label: 'Camera',
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.palmAshGray.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.ricePaddyGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.ricePaddyGreen),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable image picker widget for forms
class ImagePickerWidget extends StatelessWidget {
  final String? imageUrl;
  final dynamic imageFile; // Can be File or PickedImage
  final VoidCallback onTap;
  final String? label;
  final double height;
  final double? width;
  final Widget? placeholder;
  final bool isLoading;

  const ImagePickerWidget({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.onTap,
    this.label,
    this.height = 200,
    this.width,
    this.placeholder,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],

        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Container(
            width: width ?? double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.bambooCream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.palmAshGray.withOpacity(0.3)),
              image: _getBackgroundImage(),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    _hasImage()
                        ? Colors.black.withOpacity(0.3)
                        : Colors.transparent,
              ),
              child:
                  isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.ricePaddyGreen,
                        ),
                      )
                      : Center(
                        child:
                            _hasImage()
                                ? _buildImageOverlay(theme)
                                : _buildPlaceholder(theme),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  DecorationImage? _getBackgroundImage() {
    if (imageFile != null) {
      if (kIsWeb) {
        // Handle web platform
        if (imageFile is PickedImage &&
            (imageFile as PickedImage).webPath != null) {
          return DecorationImage(
            image: NetworkImage((imageFile as PickedImage).webPath!),
            fit: BoxFit.cover,
          );
        }
      } else {
        // Handle mobile platforms
        if (imageFile is PickedImage &&
            (imageFile as PickedImage).file != null) {
          return DecorationImage(
            image: FileImage((imageFile as PickedImage).file!),
            fit: BoxFit.cover,
          );
        } else if (imageFile is File) {
          return DecorationImage(
            image: FileImage(imageFile as File),
            fit: BoxFit.cover,
          );
        }
      }
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover);
    }

    return null;
  }

  bool _hasImage() {
    return imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty);
  }

  Widget _buildImageOverlay(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 40, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          'Tap to change image',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    if (placeholder != null) {
      return placeholder!;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 48, color: AppColors.palmAshGray),
        const SizedBox(height: 12),
        Text(
          'Tap to add image',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.palmAshGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Gallery or Camera',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.palmAshGray.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

/// Circular image picker for profile pictures
class CircularImagePicker extends StatelessWidget {
  final String? imageUrl;
  final dynamic imageFile; // Can be File or PickedImage
  final VoidCallback onTap;
  final double radius;
  final bool isLoading;
  final Widget? placeholder;

  const CircularImagePicker({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.onTap,
    this.radius = 60,
    this.isLoading = false,
    this.placeholder,
  });
  @override
  Widget build(BuildContext context) {
    debugPrint(
      'CircularImagePicker build - imageFile: ${imageFile?.path}, imageUrl: $imageUrl, hasImage: ${_hasImage()}',
    );

    return Stack(
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ricePaddyGreen,
            image:
                _getBackgroundImage() != null
                    ? DecorationImage(
                      image: _getBackgroundImage()!,
                      fit: BoxFit.cover,
                    )
                    : null,
          ),
          child:
              _hasImage() || isLoading
                  ? null
                  : Center(
                    child:
                        placeholder ??
                        Icon(Icons.person, size: radius, color: Colors.white),
                  ),
        ),

        if (isLoading)
          Positioned.fill(
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),

        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.ricePaddyGreen,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: IconButton(
              icon: Icon(
                isLoading ? Icons.hourglass_empty : Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
              onPressed: isLoading ? null : onTap,
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _getBackgroundImage() {
    // Prioritize the file image over the URL image
    // This ensures that newly selected images show up immediately
    if (imageFile != null) {
      try {
        if (kIsWeb) {
          // For web platform
          if (imageFile is PickedImage) {
            // If we have a webPath for web platform
            if ((imageFile as PickedImage).webPath != null) {
              return NetworkImage((imageFile as PickedImage).webPath!);
            }
          }
        } else {
          // For mobile platforms
          if (imageFile is PickedImage &&
              (imageFile as PickedImage).file != null) {
            return FileImage((imageFile as PickedImage).file!);
          } else if (imageFile is File && imageFile.existsSync()) {
            return FileImage(imageFile as File);
          }
        }
      } catch (e) {
        debugPrint('Error loading image file: $e');
      }
    }

    // Fall back to URL image if file image fails or is not available
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }

    return null;
  }

  bool _hasImage() {
    if (imageFile != null) {
      // Handle PickedImage or File
      return true;
    }
    return imageUrl != null && imageUrl!.isNotEmpty;
  }
}

/// Extension to simplify image source enum usage
extension ImageSourceExtension on ImageSource {
  String get displayName {
    switch (this) {
      case ImageSource.gallery:
        return 'Gallery';
      case ImageSource.camera:
        return 'Camera';
    }
  }

  IconData get icon {
    switch (this) {
      case ImageSource.gallery:
        return Icons.photo_library;
      case ImageSource.camera:
        return Icons.photo_camera;
    }
  }
}
