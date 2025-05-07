import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../services/api_config.dart';
import '../services/api_service.dart';
import '../services/localization_service.dart';
import '../services/network_info.dart';
import '../services/storage_service.dart';

/// Registers all core singletons with their dependencies.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    /// Secure key-value storage
    Get.lazyPut<StorageService>(() => StorageService());

    /// Connectivity checker
    Get.lazyPut<Connectivity>(() => Connectivity());
    Get.lazyPut<NetworkInfo>(() => NetworkInfoImpl(Get.find()));

    /// Logger for debug/info/error logs
    Get.lazyPut<Logger>(() => Logger());

    /// HTTP client
    Get.lazyPut<http.Client>(() => http.Client());

    /// API configuration (base URL, timeouts, retry)
    Get.lazyPut<ApiConfig>(
      () => ApiConfig(baseUrl: AppConstants.baseUrl),
    );

    /// Registers LocalizationService for managing app languages.
    Get.lazyPut<LocalizationService>(() => LocalizationService());

    /// Central HTTP service, wired with client, config, connectivity, logger, storage
    Get.lazyPut<ApiService>(
      () => ApiService(
        client: Get.find<http.Client>(),
        config: Get.find<ApiConfig>(),
        connectivity: Get.find<Connectivity>(),
        logger: Get.find<Logger>(),
      ),
    );
  }
}
