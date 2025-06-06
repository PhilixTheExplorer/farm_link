import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user.dart';
import '../models/buyer.dart';
import '../models/farmer.dart';
import '../services/user_service.dart';
import '../services/buyer_service.dart';
import '../services/farmer_service.dart';
import '../core/di/service_locator.dart';

// State class for profile edit
class ProfileEditState {
  final User? user;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final File? selectedImage;
  final bool hasUnsavedChanges;

  // Form key for validation
  final GlobalKey<FormState> formKey;

  // Text controllers for form fields
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController deliveryAddressController;
  final TextEditingController deliveryInstructionsController;
  final TextEditingController farmNameController;
  final TextEditingController farmAddressController;
  final TextEditingController farmDescriptionController;

  // Form data
  final String name;
  final String phone;
  final String location;

  // Buyer-specific fields
  final String deliveryAddress;
  final String deliveryInstructions;
  final List<String> preferences;

  // Farmer-specific fields
  final String farmName;
  final String farmAddress;
  final String farmDescription;

  ProfileEditState({
    this.user,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.selectedImage,
    this.hasUnsavedChanges = false,
    GlobalKey<FormState>? formKey,
    TextEditingController? nameController,
    TextEditingController? phoneController,
    TextEditingController? locationController,
    TextEditingController? deliveryAddressController,
    TextEditingController? deliveryInstructionsController,
    TextEditingController? farmNameController,
    TextEditingController? farmAddressController,
    TextEditingController? farmDescriptionController,
    this.name = '',
    this.phone = '',
    this.location = '',
    this.deliveryAddress = '',
    this.deliveryInstructions = '',
    this.preferences = const [],
    this.farmName = '',
    this.farmAddress = '',
    this.farmDescription = '',
  }) : formKey = formKey ?? GlobalKey<FormState>(),
       nameController = nameController ?? TextEditingController(),
       phoneController = phoneController ?? TextEditingController(),
       locationController = locationController ?? TextEditingController(),
       deliveryAddressController =
           deliveryAddressController ?? TextEditingController(),
       deliveryInstructionsController =
           deliveryInstructionsController ?? TextEditingController(),
       farmNameController = farmNameController ?? TextEditingController(),
       farmAddressController = farmAddressController ?? TextEditingController(),
       farmDescriptionController =
           farmDescriptionController ?? TextEditingController();

  ProfileEditState copyWith({
    User? user,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    File? selectedImage,
    bool? hasUnsavedChanges,
    String? name,
    String? phone,
    String? location,
    String? deliveryAddress,
    String? deliveryInstructions,
    List<String>? preferences,
    String? farmName,
    String? farmAddress,
    String? farmDescription,
  }) {
    return ProfileEditState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      selectedImage: selectedImage ?? this.selectedImage,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      formKey: formKey,
      nameController: nameController,
      phoneController: phoneController,
      locationController: locationController,
      deliveryAddressController: deliveryAddressController,
      deliveryInstructionsController: deliveryInstructionsController,
      farmNameController: farmNameController,
      farmAddressController: farmAddressController,
      farmDescriptionController: farmDescriptionController,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      preferences: preferences ?? this.preferences,
      farmName: farmName ?? this.farmName,
      farmAddress: farmAddress ?? this.farmAddress,
      farmDescription: farmDescription ?? this.farmDescription,
    );
  }

  // Computed properties
  UserRole? get userRole {
    if (user is Buyer) return UserRole.buyer;
    if (user is Farmer) return UserRole.farmer;
    return null;
  }

  bool get isBuyer => userRole == UserRole.buyer;
  bool get isFarmer => userRole == UserRole.farmer;

  // Form validation
  bool get isFormValid {
    return name.trim().isNotEmpty &&
        phone.trim().isNotEmpty &&
        location.trim().isNotEmpty;
  }

  String? validateName(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Name is required';
    if ((value?.trim().length ?? 0) < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Phone number is required';
    if ((value?.trim().length ?? 0) < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  String? validateLocation(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Location is required';
    return null;
  }

  String? validateDeliveryAddress(String? value) {
    if (isBuyer && (value?.trim().isEmpty ?? true)) {
      return 'Delivery address is required';
    }
    return null;
  }

  String? validateFarmName(String? value) {
    if (isFarmer && (value?.trim().isEmpty ?? true)) {
      return 'Farm name is required';
    }
    return null;
  }

  String? validateFarmAddress(String? value) {
    if (isFarmer && (value?.trim().isEmpty ?? true)) {
      return 'Farm address is required';
    }
    return null;
  }

  // Dispose controllers
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    deliveryAddressController.dispose();
    deliveryInstructionsController.dispose();
    farmNameController.dispose();
    farmAddressController.dispose();
    farmDescriptionController.dispose();
  }
}

// ViewModel for profile edit
class ProfileEditViewModel extends StateNotifier<ProfileEditState> {
  final UserService _userService;
  final BuyerService _buyerService;
  final FarmerService _farmerService;
  final ImagePicker _imagePicker = ImagePicker();
  ProfileEditViewModel(
    this._userService,
    this._buyerService,
    this._farmerService,
  ) : super(ProfileEditState()) {
    _initializeForm();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final user = _userService.currentUser;
    if (user == null) return;

    if (user is Buyer) {
      state = state.copyWith(
        user: user,
        name: user.name ?? '',
        phone: user.phone ?? '',
        location: user.location ?? '',
        deliveryAddress: user.deliveryAddress ?? '',
        deliveryInstructions: user.deliveryInstructions ?? '',
        preferences:
            user.preferences
                ?.map((apiValue) => _mapApiToPaymentMethodUI(apiValue))
                .toList() ??
            [],
      );
    } else if (user is Farmer) {
      state = state.copyWith(
        user: user,
        name: user.name ?? '',
        phone: user.phone ?? '',
        location: user.location ?? '',
        farmName: user.farmName ?? '',
        farmAddress: user.farmAddress ?? '',
        farmDescription: user.farmDescription ?? '',
      );
    }

    // Update text controllers
    _updateControllers();
  }

  void _updateControllers() {
    state.nameController.text = state.name;
    state.phoneController.text = state.phone;
    state.locationController.text = state.location;
    state.deliveryAddressController.text = state.deliveryAddress;
    state.deliveryInstructionsController.text = state.deliveryInstructions;
    state.farmNameController.text = state.farmName;
    state.farmAddressController.text = state.farmAddress;
    state.farmDescriptionController.text = state.farmDescription;
  }

  // Map API preference values to UI display names
  String _mapApiToPaymentMethodUI(String apiValue) {
    switch (apiValue) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'cash_on_delivery':
        return 'Cash on Delivery';
      case 'credit_card':
        return 'Credit Card';
      case 'digital_wallet':
        return 'Digital Wallet';
      default:
        return apiValue; // Return as-is if no mapping found
    }
  }

  // Map UI display names to API values
  String _mapPaymentMethodUIToApi(String uiValue) {
    switch (uiValue) {
      case 'Bank Transfer':
        return 'bank_transfer';
      case 'Cash on Delivery':
        return 'cash_on_delivery';
      case 'Credit Card':
        return 'credit_card';
      case 'Digital Wallet':
        return 'digital_wallet';
      default:
        return uiValue.toLowerCase().replaceAll(' ', '_');
    }
  }

  // Update form fields
  void updateName(String value) {
    state = state.copyWith(name: value, hasUnsavedChanges: true);
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value, hasUnsavedChanges: true);
  }

  void updateLocation(String value) {
    state = state.copyWith(location: value, hasUnsavedChanges: true);
  }

  void updateDeliveryAddress(String value) {
    state = state.copyWith(deliveryAddress: value, hasUnsavedChanges: true);
  }

  void updateDeliveryInstructions(String value) {
    state = state.copyWith(
      deliveryInstructions: value,
      hasUnsavedChanges: true,
    );
  }

  void updatePreferences(List<String> value) {
    state = state.copyWith(preferences: value, hasUnsavedChanges: true);
  }

  void updateFarmName(String value) {
    state = state.copyWith(farmName: value, hasUnsavedChanges: true);
  }

  void updateFarmAddress(String value) {
    state = state.copyWith(farmAddress: value, hasUnsavedChanges: true);
  }

  void updateFarmDescription(String value) {
    state = state.copyWith(farmDescription: value, hasUnsavedChanges: true);
  }

  // Validation methods for use in the UI
  String? validateName(String? value) => state.validateName(value);
  String? validatePhone(String? value) => state.validatePhone(value);
  String? validateLocation(String? value) => state.validateLocation(value);
  String? validateDeliveryAddress(String? value) =>
      state.validateDeliveryAddress(value);
  String? validateFarmName(String? value) => state.validateFarmName(value);
  String? validateFarmAddress(String? value) =>
      state.validateFarmAddress(value);

  // Image selection
  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        state = state.copyWith(
          selectedImage: File(image.path),
          hasUnsavedChanges: true,
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      state = state.copyWith(
        errorMessage: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        state = state.copyWith(
          selectedImage: File(image.path),
          hasUnsavedChanges: true,
        );
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      state = state.copyWith(
        errorMessage: 'Failed to take photo: ${e.toString()}',
      );
    }
  }

  // Save profile
  Future<void> saveProfile() async {
    if (!state.formKey.currentState!.validate()) {
      return;
    }

    try {
      state = state.copyWith(
        isSaving: true,
        errorMessage: null,
        successMessage: null,
      );

      if (state.isBuyer) {
        await _saveBuyerProfile();
      } else if (state.isFarmer) {
        await _saveFarmerProfile();
      }

      state = state.copyWith(
        isSaving: false,
        hasUnsavedChanges: false,
        successMessage: 'Profile updated successfully!',
      );

      // Refresh the user data in the state
      final updatedUser = _userService.currentUser;
      if (updatedUser != null) {
        state = state.copyWith(user: updatedUser);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save profile: ${e.toString()}',
      );
    }
  }

  Future<void> _saveBuyerProfile() async {
    final apiPreferences =
        state.preferences
            .map((uiValue) => _mapPaymentMethodUIToApi(uiValue))
            .toList();

    final buyerData = <String, dynamic>{
      'name': state.nameController.text.trim(),
      'phone': state.phoneController.text.trim(),
      'location': state.locationController.text.trim(),
      'delivery_address':
          state.deliveryAddressController.text.trim().isEmpty
              ? null
              : state.deliveryAddressController.text.trim(),
      'delivery_instructions':
          state.deliveryInstructionsController.text.trim().isEmpty
              ? null
              : state.deliveryInstructionsController.text.trim(),
      'preferred_payment_methods': apiPreferences,
    };

    // Remove null values
    buyerData.removeWhere((key, value) => value == null);

    await _buyerService.updateBuyerProfile(state.user!.id, buyerData);
  }

  Future<void> _saveFarmerProfile() async {
    final farmerData = <String, dynamic>{
      'name': state.nameController.text.trim(),
      'phone': state.phoneController.text.trim(),
      'location': state.locationController.text.trim(),
      'farm_name':
          state.farmNameController.text.trim().isEmpty
              ? null
              : state.farmNameController.text.trim(),
      'farm_address':
          state.farmAddressController.text.trim().isEmpty
              ? null
              : state.farmAddressController.text.trim(),
      'farm_description':
          state.farmDescriptionController.text.trim().isEmpty
              ? null
              : state.farmDescriptionController.text.trim(),
    };

    // Remove null values
    farmerData.removeWhere((key, value) => value == null);

    await _farmerService.updateFarmerProfile(state.user!.id, farmerData);
  }

  // Clear messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  // Refresh form data from API
  Future<void> refreshFormData() async {
    // For now, just reinitialize with cached data
    // API refresh happens in ProfileSettingsView when returning from edit
    _initializeForm();
  }

  // Reset form to original values
  void resetForm() {
    _initializeForm();
    state = state.copyWith(
      selectedImage: null,
      hasUnsavedChanges: false,
      errorMessage: null,
      successMessage: null,
    );
  }
}

// Provider for profile edit
final profileEditViewModelProvider =
    StateNotifierProvider<ProfileEditViewModel, ProfileEditState>((ref) {
      final userService = serviceLocator<UserService>();
      final buyerService = serviceLocator<BuyerService>();
      final farmerService = serviceLocator<FarmerService>();
      return ProfileEditViewModel(userService, buyerService, farmerService);
    });
