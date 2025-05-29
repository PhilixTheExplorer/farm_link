import 'package:farm_link/screens/connect_test_view.dart';
import 'package:farm_link/screens/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/navigation_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_register_view.dart';
import 'screens/farmer_dashboard_view.dart';
import 'screens/buyer_marketplace_view.dart';
import 'screens/product_upload_view.dart';
import 'screens/product_detail_view.dart';
import 'screens/cart_view.dart';
import 'screens/order_confirmation_view.dart';
import 'screens/impact_tracker_view.dart';
import 'screens/profile_settings_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmLink',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: '/buyer-marketplace',
      routes: {
        '/connect-test': (context) => ConnectTestView(),
        '/home': (context) => const HomeView(),
        '/login': (context) => const LoginRegisterView(),
        '/farmer-dashboard': (context) => const FarmerDashboardView(),
        '/buyer-marketplace': (context) => const BuyerMarketplaceView(),
        '/product-upload': (context) => const ProductUploadView(),
        '/product-detail': (context) => const ProductDetailView(),
        '/cart': (context) => const CartView(),
        '/order-confirmation': (context) => const OrderConfirmationView(),
        '/impact-tracker': (context) => const ImpactTrackerView(),
        '/profile-settings': (context) => const ProfileSettingsView(),
      },
    );
  }
}
