// lib/features/auth/presentation/bindings/auth_binding.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/api_config.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/network_info.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../controllers/auth_controller.dart';

/// Dependency injection bindings for the Auth feature.
/// Registers all classes required for authentication flows,
/// including network clients, data sources, repository, use cases, and controller.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // ----------------------------------------------------------------------
    // Core and third-party services
    // ----------------------------------------------------------------------

    /// Registers a singleton [http.Client] for making HTTP requests.
    Get.lazyPut<http.Client>(() => http.Client());

    /// Registers [GetStorage] for lightweight local key-value storage.
    Get.lazyPut<GetStorage>(() => GetStorage());

    /// Registers [Logger] for structured logging throughout the app.
    Get.lazyPut<Logger>(() => Logger());

    /// Registers [Connectivity] to observe network status changes.
    Get.lazyPut<Connectivity>(() => Connectivity());

    // ----------------------------------------------------------------------
    // API configuration and service
    // ----------------------------------------------------------------------

    /// Registers [ApiConfig] with base URL, timeout, and retry policies.
    Get.lazyPut<ApiConfig>(() => ApiConfig(
          baseUrl: AppConstants.baseUrl,
          timeout: const Duration(seconds: 30),
        ));

    /// Registers [ApiService], injecting HTTP client, config, connectivity, and logger.
    Get.lazyPut<ApiService>(() => ApiService(
          client: Get.find<http.Client>(),
          config: Get.find<ApiConfig>(),
          connectivity: Get.find<Connectivity>(),
          logger: Get.find<Logger>(),
        ));

    // ----------------------------------------------------------------------
    // Data layer
    // ----------------------------------------------------------------------

    /// Registers [AuthRemoteDataSource], which uses [ApiService] to call auth endpoints.
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(Get.find<ApiService>()),
    );

    /// Registers [AuthRepositoryImpl] as the implementation of [AuthRepository].
    /// Combines remote data source, local storage, and API service.
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: Get.find<AuthRemoteDataSource>(),
        storage: Get.find<GetStorage>(),
        apiService: Get.find<ApiService>(),
      ),
    );

    // ----------------------------------------------------------------------
    // Domain layer (use cases)
    // ----------------------------------------------------------------------

    /// Registers [LoginUseCase], encapsulating login business logic.
    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(
          repository: Get.find<AuthRepository>(),
          network: NetworkInfoImpl(Get.find())),
    );

    // ----------------------------------------------------------------------
    // Presentation layer (controller)
    // ----------------------------------------------------------------------

    /// Registers [AuthController], which manages the login state and UI interactions.
    Get.lazyPut<AuthController>(
      () => AuthController(loginUseCase: Get.find<LoginUseCase>()),
    );
  }
}
