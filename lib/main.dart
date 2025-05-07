// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx/routes/app_pages.dart';
import 'package:getx/routes/app_routes.dart';

import 'core/bindings/initial_binding.dart';
import 'core/services/localization_service.dart';
import 'core/theme/app_theme.dart';

/// Entry point of the application.
/// Ensures bindings are initialized before running the app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  InitialBinding().dependencies();
  runApp(const MyApp());
}

/// Root widget of the application using GetMaterialApp for GetX features.
/// Configured with multi-language support.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Disable debug banner
      debugShowCheckedModeBanner: false,

      // App title
      title: 'My App',

      // Internationalization
      translations: LocalizationService(),
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.fallbackLocale,

      // Initial route configuration
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,

      // Theming
      theme: AppTheme.lightTheme,
    );
  }
}
