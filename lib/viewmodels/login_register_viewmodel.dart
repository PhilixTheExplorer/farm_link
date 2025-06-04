import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class LoginRegisterViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  // Form controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // State
  AuthViewState _viewState = const AuthViewState();
  String _selectedRole = 'Farmer';

  // Getters
  AuthViewState get viewState => _viewState;
  String get selectedRole => _selectedRole;
  bool get isLoading => _viewState.state == AuthState.loading;
  bool get isLoginPasswordVisible => _viewState.isPasswordVisible;
  bool get isRegisterPasswordVisible => _viewState.isConfirmPasswordVisible;

  // Current models
  LoginModel get loginModel => LoginModel(
    email: loginEmailController.text.trim(),
    password: loginPasswordController.text,
  );

  RegisterModel get registerModel => RegisterModel(
    email: registerEmailController.text.trim(),
    password: registerPasswordController.text,
    confirmPassword: confirmPasswordController.text,
    role: _selectedRole.toLowerCase(),
  );

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Actions
  void toggleLoginPasswordVisibility() {
    _viewState = _viewState.copyWith(
      isPasswordVisible: !_viewState.isPasswordVisible,
    );
    notifyListeners();
  }

  void toggleRegisterPasswordVisibility() {
    _viewState = _viewState.copyWith(
      isConfirmPasswordVisible: !_viewState.isConfirmPasswordVisible,
    );
    notifyListeners();
  }

  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void clearError() {
    if (_viewState.state == AuthState.error) {
      _viewState = _viewState.copyWith(
        state: AuthState.initial,
        errorMessage: null,
      );
      notifyListeners();
    }
  }

  // Validation methods
  String? validateLoginEmail(String? value) => loginModel.validateEmail();
  String? validateLoginPassword(String? value) => loginModel.validatePassword();
  String? validateRegisterEmail(String? value) => registerModel.validateEmail();
  String? validateRegisterPassword(String? value) =>
      registerModel.validatePassword();
  String? validateConfirmPassword(String? value) =>
      registerModel.validateConfirmPassword();

  // Authentication methods
  Future<bool> login() async {
    if (!loginFormKey.currentState!.validate()) {
      return false;
    }

    _setLoading(true);

    try {
      final model = loginModel;
      final result = await _userService.login(model.email, model.password);

      if (result.isSuccess) {
        _setSuccess();
        return true;
      } else {
        _setError(
          result.errorMessage ?? 'Login failed. Please check your credentials.',
        );
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<bool> register() async {
    if (!registerFormKey.currentState!.validate()) {
      return false;
    }

    _setLoading(true);

    try {
      final model = registerModel;
      final result = await _userService.register(
        model.email,
        model.password,
        model.role,
      );

      if (result.isSuccess) {
        _setSuccess();
        return true;
      } else {
        _setError(
          result.errorMessage ?? 'Registration failed. Please try again.',
        );
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Navigation helpers
  String getNavigationDestination() {
    final userService = UserService();
    return userService.currentUserRole == UserRole.farmer
        ? '/farmer-dashboard'
        : '/buyer-marketplace';
  }

  String getRegistrationDestination() {
    return _selectedRole == 'Farmer'
        ? '/farmer-dashboard'
        : '/buyer-marketplace';
  }

  // Private methods
  void _setLoading(bool loading) {
    _viewState = _viewState.copyWith(
      state: loading ? AuthState.loading : AuthState.initial,
      errorMessage: null,
    );
    notifyListeners();
  }

  void _setSuccess() {
    _viewState = _viewState.copyWith(
      state: AuthState.success,
      errorMessage: null,
    );
    notifyListeners();
  }

  void _setError(String message) {
    _viewState = _viewState.copyWith(
      state: AuthState.error,
      errorMessage: message,
    );
    notifyListeners();
  }
}
