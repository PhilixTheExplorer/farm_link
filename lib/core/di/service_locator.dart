import 'package:get_it/get_it.dart';
import '../../services/api_service.dart';
import '../../services/user_service.dart';
import '../../services/product_service.dart';
import '../../services/farmer_service.dart';
import '../../services/buyer_service.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/farmer_repository.dart';
import '../../repositories/buyer_repository.dart';
import '../../viewmodels/farmer_dashboard_viewmodel.dart';

final GetIt serviceLocator = GetIt.instance;

/// Initialize all dependencies for dependency injection
Future<void> setupServiceLocator() async {
  // Register repositories (singletons)
  serviceLocator.registerLazySingleton<UserRepository>(() => UserRepository());
  serviceLocator.registerLazySingleton<ProductRepository>(
    () => ProductRepository(),
  );
  serviceLocator.registerLazySingleton<FarmerRepository>(
    () => FarmerRepository(),
  );
  serviceLocator.registerLazySingleton<BuyerRepository>(
    () => BuyerRepository(),
  );

  // Register services (singletons)
  serviceLocator.registerLazySingleton<ApiService>(() => ApiService());
  serviceLocator.registerLazySingleton<UserService>(() => UserService());
  serviceLocator.registerLazySingleton<ProductService>(() => ProductService());
  serviceLocator.registerLazySingleton<FarmerService>(() => FarmerService());
  serviceLocator.registerLazySingleton<BuyerService>(() => BuyerService());

  // Register view models (singletons)
  serviceLocator.registerLazySingleton<FarmerDashboardViewModel>(
    () => FarmerDashboardViewModel(),
  );

  // Initialize services that need setup
  await serviceLocator.get<UserService>().initialize();
}

/// Reset all registrations (useful for testing)
void resetServiceLocator() {
  serviceLocator.reset();
}
