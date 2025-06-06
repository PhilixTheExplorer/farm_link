import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../components/payment_method_selector.dart';
import '../core/theme/app_colors.dart';
import '../services/user_service.dart';
import '../services/buyer_service.dart';
import '../services/farmer_service.dart';
import '../models/buyer.dart';
import '../models/farmer.dart';
import '../core/di/service_locator.dart';

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final UserService _userService = serviceLocator<UserService>();
  final BuyerService _buyerService = serviceLocator<BuyerService>();
  final FarmerService _farmerService = serviceLocator<FarmerService>();
  final ImagePicker _imagePicker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _selectedImage;

  // Common form controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  // Buyer specific controllers
  late TextEditingController _deliveryAddressController;
  List<String> _preferences = [];

  // Farmer specific controllers
  late TextEditingController _farmNameController;
  late TextEditingController _farmAddressController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = _userService.currentUser!;

    // Common fields
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _locationController = TextEditingController(text: user.location);
    if (user is Buyer) {
      // Buyer specific fields
      _deliveryAddressController = TextEditingController(
        text: user.deliveryAddress ?? '',
      );
      _preferences = user.preferences?.toList() ?? [];
    } else if (user is Farmer) {
      // Farmer specific fields
      _farmNameController = TextEditingController(text: user.farmName ?? '');
      _farmAddressController = TextEditingController(
        text: user.farmAddress ?? '',
      );
      _descriptionController = TextEditingController(
        text: user.description ?? '',
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      // Show bottom sheet to choose between camera and gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder:
            (context) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Camera'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ],
              ),
            ),
      );

      if (source != null) {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1080,
          maxHeight: 1080,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.chilliRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _deliveryAddressController.dispose();
    _farmNameController.dispose();
    _farmAddressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _userService.currentUser!;

      if (user is Buyer) {
        await _updateBuyerProfile();
      } else if (user is Farmer) {
        await _updateFarmerProfile();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.ricePaddyGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.chilliRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateBuyerProfile() async {
    final buyer = _userService.currentUser as Buyer;

    final updatedData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'location': _locationController.text.trim(),
      'delivery_address': _deliveryAddressController.text.trim(),
      'preferences': _preferences,
    };

    // TODO: Add image upload when backend supports it
    if (_selectedImage != null) {
      debugPrint('Profile image selected but upload not implemented yet');
      // In the future, this would upload the image and add the URL to updatedData
      // updatedData['profile_image_url'] = await _uploadImage(_selectedImage!);
    }

    await _buyerService.updateBuyerProfile(buyer.id, updatedData);
  }

  Future<void> _updateFarmerProfile() async {
    final farmer = _userService.currentUser as Farmer;

    final updatedData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'location': _locationController.text.trim(),
      'farm_name': _farmNameController.text.trim(),
      'farm_address': _farmAddressController.text.trim(),
      'description': _descriptionController.text.trim(),
    };

    // TODO: Add image upload when backend supports it
    if (_selectedImage != null) {
      debugPrint('Profile image selected but upload not implemented yet');
      // In the future, this would upload the image and add the URL to updatedData
      // updatedData['profile_image_url'] = await _uploadImage(_selectedImage!);
    }

    await _farmerService.updateFarmerProfile(farmer.id, updatedData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _userService.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (user.profileImageUrl != null
                                      ? NetworkImage(user.profileImageUrl!)
                                      : null),
                          backgroundColor: AppColors.ricePaddyGreen,
                          child:
                              _selectedImage == null &&
                                      user.profileImageUrl == null
                                  ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                  : null,
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
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to change profile picture',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.palmAshGray,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Common Profile Fields
              Text(
                'Basic Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ThaiTextField(
                label: 'Full Name',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ThaiTextField(
                label: 'Phone Number',
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter your phone number';
                  }
                  // Basic phone number validation
                  final phoneRegex = RegExp(r'^[0-9\+\-\s\(\)]+$');
                  if (!phoneRegex.hasMatch(value!.trim())) {
                    return 'Please enter a valid phone number';
                  }
                  if (value.trim().length < 10) {
                    return 'Phone number must be at least 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ThaiTextField(
                label: 'Location',
                controller: _locationController,
                prefixIcon: Icons.location_on_outlined,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter your location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Role-specific fields
              if (user is Buyer)
                ..._buildBuyerFields(theme)
              else if (user is Farmer)
                ..._buildFarmerFields(theme),

              const SizedBox(height: 32),

              // Save Button
              ThaiButton(
                label: 'Save Changes',
                onPressed: _isLoading ? null : _saveProfile,
                isFullWidth: true,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBuyerFields(ThemeData theme) {
    return [
      Text(
        'Delivery & Preferences',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      ThaiTextField(
        label: 'Default Delivery Address',
        controller: _deliveryAddressController,
        prefixIcon: Icons.home_outlined,
        maxLines: 3,
        hintText: 'Enter your preferred delivery address',
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Please enter your delivery address';
          }
          if (value!.trim().length < 10) {
            return 'Please enter a more detailed address';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      // Payment Method Preferences
      PaymentMethodSelector(
        selectedMethods: _preferences,
        onSelectionChanged: (methods) {
          setState(() {
            _preferences = methods;
          });
        },
      ),
    ];
  }

  List<Widget> _buildFarmerFields(ThemeData theme) {
    return [
      Text(
        'Farm Information',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      ThaiTextField(
        label: 'Farm Name',
        controller: _farmNameController,
        prefixIcon: Icons.agriculture_outlined,
        hintText: 'Enter your farm name',
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Please enter your farm name';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      ThaiTextField(
        label: 'Farm Address',
        controller: _farmAddressController,
        prefixIcon: Icons.location_on_outlined,
        maxLines: 2,
        hintText: 'Enter your farm address',
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Please enter your farm address';
          }
          if (value!.trim().length < 10) {
            return 'Please enter a more detailed address';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      ThaiTextField(
        label: 'Farm Description',
        controller: _descriptionController,
        prefixIcon: Icons.description_outlined,
        maxLines: 4,
        hintText: 'Describe your farm, farming methods, specialties, etc.',
      ),
      const SizedBox(height: 16),

      // Farm verification status (read-only)
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.ricePaddyGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.ricePaddyGreen.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              (_userService.currentUser as Farmer).isVerified
                  ? Icons.verified
                  : Icons.pending,
              color:
                  (_userService.currentUser as Farmer).isVerified
                      ? AppColors.ricePaddyGreen
                      : AppColors.palmAshGray,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Status',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    (_userService.currentUser as Farmer).isVerified
                        ? 'Your farm is verified'
                        : 'Verification pending',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.palmAshGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
