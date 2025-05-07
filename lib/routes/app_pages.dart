// lib/routes/app_pages.dart

import 'package:get/get.dart';

import '../features/auth/presentation/bindings/auth_binding.dart';
import '../features/auth/presentation/views/login_page.dart';
import 'app_routes.dart';

/// Holds the list of application routes and their configurations.
/// Each route is defined with a unique name, the widget to display,
/// and any dependency bindings required before rendering.
class AppPages {
  /// A list of GetPage objects that define app navigation.
  ///
  /// - [name]: Unique route identifier (used in navigation calls).
  /// - [page]: Function that returns the page widget.
  /// - [binding]: Dependency injection binding executed before the page loads.
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
  ];
}
