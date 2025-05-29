import '../models/user.dart';
import '../models/farmer.dart';
import '../models/buyer.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();
  // Placeholder data - in real app this would come from backend
  static final List<Farmer> _sampleFarmers = [
    Farmer(
      id: 'farmer_001',
      email: 'somchai@farmlink.th',
      name: 'Somchai Jaidee',
      phone: '+66 81 234 5678',
      location: 'Chiang Mai',
      joinDate: DateTime(2023, 3, 15),
      farmName: 'Golden Rice Farm',
      farmSize: 15.5,
      cropTypes: ['Rice', 'Vegetables', 'Herbs'],
      farmingMethod: 'Organic',
      rating: 4.8,
      totalSales: 127,
      isVerified: true,
      certifications: 'Organic Thailand Certification',
      profileImageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    ),
    Farmer(
      id: 'farmer_002',
      email: 'malee@farmlink.th',
      name: 'Malee Suwan',
      phone: '+66 82 345 6789',
      location: 'Nakhon Pathom',
      joinDate: DateTime(2023, 5, 20),
      farmName: 'Fresh Greens Farm',
      farmSize: 8.2,
      cropTypes: ['Lettuce', 'Spinach', 'Kale', 'Tomatoes'],
      farmingMethod: 'Hydroponic',
      rating: 4.6,
      totalSales: 89,
      isVerified: true,
      certifications: 'GAP Certification',
      profileImageUrl: null, // This user will show the default avatar
    ),
  ];
  static final List<Buyer> _sampleBuyers = [
    Buyer(
      id: 'buyer_001',
      email: 'john.doe@email.com',
      name: 'John Doe',
      phone: '+66 91 234 5678',
      location: 'Bangkok',
      joinDate: DateTime(2023, 4, 10),
      preferredDeliveryTime: 'Morning (9-12 AM)',
      dietaryPreferences: ['Organic', 'Local'],
      totalSpent: 2450.50,
      totalOrders: 15,
      favoriteProducts: ['Organic Rice', 'Fresh Vegetables'],
      deliveryAddress: '123 Sukhumvit Road, Bangkok 10110',
      subscribeToNewsletter: true,
      profileImageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    ),
    Buyer(
      id: 'buyer_002',
      email: 'sara.smith@email.com',
      name: 'Sara Smith',
      phone: '+66 92 345 6789',
      location: 'Bangkok',
      joinDate: DateTime(2023, 6, 5),
      preferredDeliveryTime: 'Evening (4-7 PM)',
      dietaryPreferences: ['Organic', 'Pesticide-free'],
      totalSpent: 1850.75,
      totalOrders: 12,
      favoriteProducts: ['Hydroponic Lettuce', 'Organic Herbs'],
      deliveryAddress: '456 Rama IV Road, Bangkok 10500',
      subscribeToNewsletter: false,
      profileImageUrl: null, // This user will show the default avatar
    ),
  ];

  // Current user simulation
  User? _currentUser;

  User? get currentUser => _currentUser;
  // Simulate login with email and password only - auto-detect role
  Future<User?> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // First check if email exists in farmers
    try {
      _currentUser = _sampleFarmers.firstWhere(
        (farmer) => farmer.email.toLowerCase() == email.toLowerCase(),
      );
      return _currentUser;
    } catch (e) {
      // If not found in farmers, check buyers
      try {
        _currentUser = _sampleBuyers.firstWhere(
          (buyer) => buyer.email.toLowerCase() == email.toLowerCase(),
        );
        return _currentUser;
      } catch (e) {
        // User not found
        return null;
      }
    }
  }

  // Get user by ID (simulate backend fetch)
  Future<User?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Search in farmers
    try {
      return _sampleFarmers.firstWhere((farmer) => farmer.id == id);
    } catch (e) {
      // Search in buyers
      try {
        return _sampleBuyers.firstWhere((buyer) => buyer.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(User updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (updatedUser is Farmer) {
      final index = _sampleFarmers.indexWhere((f) => f.id == updatedUser.id);
      if (index != -1) {
        _sampleFarmers[index] = updatedUser;
        if (_currentUser?.id == updatedUser.id) {
          _currentUser = updatedUser;
        }
        return true;
      }
    } else if (updatedUser is Buyer) {
      final index = _sampleBuyers.indexWhere((b) => b.id == updatedUser.id);
      if (index != -1) {
        _sampleBuyers[index] = updatedUser;
        if (_currentUser?.id == updatedUser.id) {
          _currentUser = updatedUser;
        }
        return true;
      }
    }

    return false;
  }

  // Get all farmers (for marketplace)
  Future<List<Farmer>> getAllFarmers() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_sampleFarmers);
  }

  // Logout
  void logout() {
    _currentUser = null;
  }

  // Switch user role (for demo purposes)
  void switchUserRole(UserRole newRole) {
    if (newRole == UserRole.farmer) {
      _currentUser = _sampleFarmers.last;
    } else {
      _currentUser = _sampleBuyers.first;
    }
  }
}
