import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/home_view.dart';
import '../../screens/login_register_view.dart';
import '../../screens/farmer_dashboard_view.dart';
import '../../screens/buyer_marketplace_view.dart';
import '../../screens/product_upload_view.dart';
import '../../screens/product_detail_view.dart';
import '../../screens/cart_view.dart';
import '../../screens/order_confirmation_view.dart';
import '../../screens/impact_tracker_view.dart';
import '../../screens/profile_settings_view.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';

/// FarmLink App Router Configuration using GoRouter
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      // Home Route
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),

      // Authentication Route
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginRegisterView(),
      ),

      // Farmer Dashboard Route
      GoRoute(
        path: '/farmer-dashboard',
        name: 'farmer-dashboard',
        builder: (context, state) => const FarmerDashboardView(),
      ),

      // Buyer Marketplace Route
      GoRoute(
        path: '/buyer-marketplace',
        name: 'buyer-marketplace',
        builder: (context, state) => const BuyerMarketplaceView(),
      ),

      // Product Upload Route
      GoRoute(
        path: '/product-upload',
        name: 'product-upload',
        builder: (context, state) => const ProductUploadView(),
      ),

      // Product Detail Route (with optional product parameter)
      GoRoute(
        path: '/product-detail',
        name: 'product-detail',
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>?;
          return ProductDetailView(product: product);
        },
      ),

      // Cart Route
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartView(),
      ),

      // Order Confirmation Route
      GoRoute(
        path: '/order-confirmation',
        name: 'order-confirmation',
        builder: (context, state) => const OrderConfirmationView(),
      ),

      // Impact Tracker Route
      GoRoute(
        path: '/impact-tracker',
        name: 'impact-tracker',
        builder: (context, state) => const ImpactTrackerView(),
      ),

      // Profile Settings Route
      GoRoute(
        path: '/profile-settings',
        name: 'profile-settings',
        builder: (context, state) => const ProfileSettingsView(),
      ),

      // Connect Test Route (if needed)
      GoRoute(
        path: '/connect-test',
        name: 'connect-test',
        builder:
            (context, state) =>
                const Scaffold(body: Center(child: Text('Connect Test Page'))),
      ),
    ],

    // Error handling
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Page Not Found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'The page "${state.fullPath}" could not be found.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ), // Optional: Add route guards/redirects
    redirect: (context, state) {
      final userService = UserService();
      final isLoggedIn = userService.isLoggedIn;
      final currentPath = state.fullPath;

      // If not logged in and trying to access protected routes, redirect to login
      const protectedRoutes = [
        '/farmer-dashboard',
        '/buyer-marketplace',
        '/product-upload',
        '/product-detail',
        '/cart',
        '/order-confirmation',
        '/impact-tracker',
        '/profile-settings',
      ];
      if (!isLoggedIn && protectedRoutes.contains(currentPath)) {
        return AppRoutes.login;
      }

      // If logged in and on login page, redirect to appropriate dashboard
      if (isLoggedIn && currentPath == AppRoutes.login) {
        final userRole = userService.currentUserRole;
        return userRole == UserRole.farmer
            ? AppRoutes.farmerDashboard
            : AppRoutes.buyerMarketplace;
      }

      // No redirect needed
      return null;
    },
  );

  static GoRouter get router => _router;

  /// Helper method to get current route name for drawer state
  static String? getCurrentRouteName() {
    final location = _router.routeInformationProvider.value.location;
    return location;
  }

  /// Navigate to a route by path
  static void navigateTo(String path, {Object? extra}) {
    _router.go(path, extra: extra);
  }

  /// Navigate and replace current route
  static void navigateAndReplace(String path, {Object? extra}) {
    _router.pushReplacement(path, extra: extra);
  }

  /// Navigate and clear stack
  static void navigateAndClearStack(String path, {Object? extra}) {
    _router.go(path, extra: extra);
  }

  /// Go back
  static void goBack() {
    _router.pop();
  }

  /// Go back with result
  static void goBackWithResult(Object? result) {
    _router.pop(result);
  }
}

/// Route path constants for easy access
class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String buyerMarketplace = '/buyer-marketplace';
  static const String farmerDashboard = '/farmer-dashboard';
  static const String productUpload = '/product-upload';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String orderConfirmation = '/order-confirmation';
  static const String impactTracker = '/impact-tracker';
  static const String profileSettings = '/profile-settings';
  static const String connectTest = '/connect-test';

  /// Helper to determine if a route should show the drawer
  static bool shouldShowDrawer(String? routeName) {
    const mainRoutes = [
      buyerMarketplace,
      farmerDashboard,
      cart,
      impactTracker,
      profileSettings,
    ];
    return mainRoutes.contains(routeName);
  }

  /// Get appropriate app bar title for route
  static String getAppBarTitle(String? routeName) {
    switch (routeName) {
      case buyerMarketplace:
        return 'Marketplace';
      case farmerDashboard:
        return 'Dashboard';
      case cart:
        return 'Cart';
      case impactTracker:
        return 'Impact Tracker';
      case profileSettings:
        return 'Profile';
      case productUpload:
        return 'Add Product';
      case productDetail:
        return 'Product Details';
      case orderConfirmation:
        return 'Order Confirmed';
      default:
        return '';
    }
  }
}
