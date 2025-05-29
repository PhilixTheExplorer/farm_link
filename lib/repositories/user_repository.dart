import '../models/user.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  // Current user (will be populated from backend API)
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Set current user (called by UserService after API login)
  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  // Logout
  void logout() {
    _currentUser = null;
  }
}
