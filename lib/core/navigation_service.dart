import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  static Future<dynamic> navigateAndReplace(String routeName) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  static Future<dynamic> navigateAndClearStack(String routeName) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }

  static void goBack() {
    return navigatorKey.currentState!.pop();
  }

  static void goBackWithResult(dynamic result) {
    return navigatorKey.currentState!.pop(result);
  }

  // Helper method to get current route name
  static String? getCurrentRouteName() {
    return ModalRoute.of(navigatorKey.currentContext!)?.settings.name;
  }

  // Route definitions for easy access
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

  // Helper to determine if a route should show the drawer
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

  // Get appropriate app bar title for route
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
