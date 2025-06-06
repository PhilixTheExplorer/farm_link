import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/buyer.dart';
import '../models/farmer.dart';
import '../services/user_service.dart';
import '../core/di/service_locator.dart';

// State class for profile settings
@immutable
class ProfileSettingsState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isEnglish;
  final bool isLoggingOut;

  const ProfileSettingsState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isEnglish = true,
    this.isLoggingOut = false,
  });

  ProfileSettingsState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isEnglish,
    bool? isLoggingOut,
  }) {
    return ProfileSettingsState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isEnglish: isEnglish ?? this.isEnglish,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }

  // Computed properties
  String get userName => user?.name ?? 'User';
  String get userEmail => user?.email ?? 'Not set';
  String get userPhone => user?.phone ?? 'Not set';
  String get userLocation => user?.location ?? 'Not set';
  String? get profileImageUrl => user?.profileImageUrl;

  UserRole? get userRole {
    if (user is Buyer) return UserRole.buyer;
    if (user is Farmer) return UserRole.farmer;
    return null;
  }

  String get roleDisplayName {
    switch (userRole) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.buyer:
        return 'Buyer';
      default:
        return 'User';
    }
  }

  // Buyer-specific getters
  Buyer? get buyerData => user is Buyer ? user as Buyer : null;
  String get deliveryAddress => buyerData?.deliveryAddress ?? 'Not set';
  int get totalOrders => buyerData?.totalOrders ?? 0;
  double get totalSpent => buyerData?.totalSpent ?? 0.0;
  List<String> get preferences => buyerData?.preferences ?? [];

  // Farmer-specific getters
  Farmer? get farmerData => user is Farmer ? user as Farmer : null;
  String get farmName => farmerData?.farmName ?? 'Not set';
  String? get farmAddress => farmerData?.farmAddress;
  String? get farmDescription => farmerData?.farmDescription;
  bool get isVerified => farmerData?.isVerified ?? false;
  int get totalSales => farmerData?.totalSales ?? 0;
}

// ViewModel for profile settings
class ProfileSettingsViewModel extends StateNotifier<ProfileSettingsState> {
  final UserService _userService;

  ProfileSettingsViewModel(this._userService)
    : super(const ProfileSettingsState()) {
    _initializeUser();
  }

  void _initializeUser() {
    final currentUser = _userService.currentUser;
    if (currentUser != null) {
      state = state.copyWith(user: currentUser);
    }
  }

  // Toggle language
  void toggleLanguage() {
    state = state.copyWith(isEnglish: !state.isEnglish);
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _userService.refreshCurrentUser();
      final updatedUser = _userService.currentUser;

      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      debugPrint('Error refreshing user: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh user data: ${e.toString()}',
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoggingOut: true, errorMessage: null);

      // Clear user session
      _userService.logout();

      state = state.copyWith(user: null, isLoggingOut: false);
    } catch (e) {
      debugPrint('Error during logout: $e');
      state = state.copyWith(
        isLoggingOut: false,
        errorMessage: 'Logout failed: ${e.toString()}',
      );
    }
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider for profile settings
final profileSettingsViewModelProvider =
    StateNotifierProvider<ProfileSettingsViewModel, ProfileSettingsState>((
      ref,
    ) {
      final userService = serviceLocator<UserService>();
      return ProfileSettingsViewModel(userService);
    });
