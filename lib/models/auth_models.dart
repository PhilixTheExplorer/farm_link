// Authentication models for MVVM pattern
class LoginModel {
  final String email;
  final String password;

  const LoginModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};

  // Validation
  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  String? validateEmail() {
    if (email.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword() {
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}

class RegisterModel {
  final String email;
  final String password;
  final String confirmPassword;
  final String role;

  const RegisterModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'role': role,
  };

  // Validation
  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      role.isNotEmpty &&
      password == confirmPassword;

  String? validateEmail() {
    if (email.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword() {
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword() {
    if (confirmPassword.isEmpty) return 'Please confirm your password';
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  String? validateRole() {
    if (role.isEmpty) return 'Please select a role';
    return null;
  }
}

// State classes for UI
enum AuthState { initial, loading, success, error }

class AuthViewState {
  final AuthState state;
  final String? errorMessage;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const AuthViewState({
    this.state = AuthState.initial,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  AuthViewState copyWith({
    AuthState? state,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return AuthViewState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}
