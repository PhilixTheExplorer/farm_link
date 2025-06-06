import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../components/payment_method_selector.dart';
import '../core/theme/app_colors.dart';
import '../viewmodels/profile_edit_viewmodel.dart';
import '../models/buyer.dart';
import '../models/farmer.dart';

class ProfileEditView extends ConsumerStatefulWidget {
  const ProfileEditView({super.key});

  @override
  ConsumerState<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends ConsumerState<ProfileEditView> {
  @override
  void initState() {
    super.initState();
    // Refresh form data when the screen loads to ensure we have latest user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileEditViewModelProvider.notifier).refreshFormData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(profileEditViewModelProvider.notifier);
    final state = ref.watch(
      profileEditViewModelProvider,
    ); // Listen to state changes for messages
    ref.listen<ProfileEditState>(profileEditViewModelProvider, (
      previous,
      next,
    ) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.ricePaddyGreen,
          ),
        );
        // Return true to indicate successful save
        context.pop(true);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.chilliRed,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          if (state.isLoading)
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
      body:
          state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(context, viewModel, state),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProfileEditViewModel viewModel,
    ProfileEditState state,
  ) {
    final theme = Theme.of(context);
    final user = state.user;

    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return Form(
      key: state.formKey,
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
                            state.selectedImage != null
                                ? FileImage(state.selectedImage!)
                                : (user.profileImageUrl != null
                                    ? NetworkImage(user.profileImageUrl!)
                                    : null),
                        backgroundColor: AppColors.ricePaddyGreen,
                        child:
                            state.selectedImage == null &&
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
                            onPressed:
                                () => _showImagePicker(context, viewModel),
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
              controller: state.nameController,
              prefixIcon: Icons.person_outline,
              validator: viewModel.validateName,
            ),
            const SizedBox(height: 16),

            ThaiTextField(
              label: 'Phone Number',
              controller: state.phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: viewModel.validatePhone,
            ),
            const SizedBox(height: 16),

            ThaiTextField(
              label: 'Location',
              controller: state.locationController,
              prefixIcon: Icons.location_on_outlined,
              validator: viewModel.validateLocation,
            ),

            const SizedBox(height: 32),

            // Role-specific fields
            if (user is Buyer)
              ..._buildBuyerFields(context, theme, viewModel, state),
            if (user is Farmer)
              ..._buildFarmerFields(context, theme, viewModel, state),

            const SizedBox(height: 32),

            // Save Button
            ThaiButton(
              label: 'Save Changes',
              onPressed: state.isLoading ? null : () => viewModel.saveProfile(),
              isFullWidth: true,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBuyerFields(
    BuildContext context,
    ThemeData theme,
    ProfileEditViewModel viewModel,
    ProfileEditState state,
  ) {
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
        controller: state.deliveryAddressController,
        prefixIcon: Icons.home_outlined,
        maxLines: 3,
        hintText: 'Enter your preferred delivery address',
        validator: viewModel.validateDeliveryAddress,
      ),
      const SizedBox(height: 16),

      ThaiTextField(
        label: 'Delivery Instructions (Optional)',
        controller: state.deliveryInstructionsController,
        prefixIcon: Icons.note_outlined,
        maxLines: 2,
        hintText: 'e.g., "Call when you arrive", "Leave at front door"',
      ),
      const SizedBox(height: 16),

      PaymentMethodSelector(
        selectedMethods: state.preferences,
        onSelectionChanged: viewModel.updatePreferences,
      ),
    ];
  }

  List<Widget> _buildFarmerFields(
    BuildContext context,
    ThemeData theme,
    ProfileEditViewModel viewModel,
    ProfileEditState state,
  ) {
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
        controller: state.farmNameController,
        prefixIcon: Icons.agriculture_outlined,
        hintText: 'Enter your farm name',
        validator: viewModel.validateFarmName,
      ),
      const SizedBox(height: 16),

      ThaiTextField(
        label: 'Farm Address',
        controller: state.farmAddressController,
        prefixIcon: Icons.location_on_outlined,
        maxLines: 2,
        hintText: 'Enter your farm address',
        validator: viewModel.validateFarmAddress,
      ),
      const SizedBox(height: 16),

      ThaiTextField(
        label: 'Farm Description',
        controller: state.farmDescriptionController,
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
              (state.user as Farmer).isVerified
                  ? Icons.verified
                  : Icons.pending,
              color:
                  (state.user as Farmer).isVerified
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
                    (state.user as Farmer).isVerified
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

  void _showImagePicker(BuildContext context, ProfileEditViewModel viewModel) {
    showModalBottomSheet<void>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickImageFromCamera();
                  },
                ),
              ],
            ),
          ),
    );
  }
}
