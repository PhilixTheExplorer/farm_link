import 'package:farm_link/core/app_theme.dart';
import 'package:farm_link/screens/farmer_dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmLink',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/farmer-dashboard',
      routes: {
        // '/connect-test': (context) => ConnectTestView(),
        // '/home': (context) => const HomeView(),
        // '/login': (context) => const LoginRegisterView(),
        '/farmer-dashboard': (context) => const FarmerDashboardView(),
        // '/buyer-marketplace': (context) => const BuyerMarketplaceView(),
        // '/product-upload': (context) => const ProductUploadView(),
        // '/product-detail': (context) => const ProductDetailView(),
        // '/cart': (context) => const CartView(),
        // '/order-confirmation': (context) => const OrderConfirmationView(),
        // '/impact-tracker': (context) => const ImpactTrackerView(),
        // '/profile-settings': (context) => const ProfileSettingsView(),
      },
    );
  }
}