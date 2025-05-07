// lib/core/language/localization_service.dart

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  // Default & fallback locales
  static const locale = Locale('en', 'US');
  static const fallbackLocale = Locale('en', 'US');

  // In-memory cache of the loaded maps
  static final Map<String, Map<String, String>> _keys = {};

  /// Call this once at app start, before runApp()
  static Future<void> init() async {
    // Load English
    final enJson = await rootBundle.loadString('assets/lang/en_US.json');
    _keys['en_US'] = Map<String, String>.from(jsonDecode(enJson));

    // Load Croatian
    final hrJson = await rootBundle.loadString('assets/lang/hr_HR.json');
    _keys['hr_HR'] = Map<String, String>.from(jsonDecode(hrJson));

    // …load more if you add them…
  }

  @override
  Map<String, Map<String, String>> get keys => _keys;
}
