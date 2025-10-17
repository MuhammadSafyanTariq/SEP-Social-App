import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../services/storage/preferences.dart';

class LanguageController extends GetxController {
  static final LanguageController _instance = LanguageController._internal();
  factory LanguageController() => _instance;
  LanguageController._internal();

  final Rx<Locale> _locale = Rx<Locale>(const Locale('en', 'US'));
  final RxString selectedLanguage = 'en'.obs;

  Locale get locale => _locale.value;

  @override
  void onInit() {
    super.onInit();
    _initializeLocale();
  }

  void _initializeLocale() {
    try {
      final savedLanguage = Preferences.language ?? 'en';
      if (!_isSupportedLanguage(savedLanguage)) {
        Logger().w('Unsupported saved language: $savedLanguage. Defaulting to English.');
        _updateLocale('en');
        return;
      }
      selectedLanguage.value = savedLanguage;
      _updateLocale(savedLanguage);
    } catch (e) {
      Logger().e('Error initializing locale: $e');
      _updateLocale('en');
    }
  }

  void updateLanguage(String language) {
    if (!_isSupportedLanguage(language)) {
      Logger().e('Unsupported language: $language');
      return;
    }
    selectedLanguage.value = language;
    Preferences.language = language;
    _updateLocale(language);
  }

  void _updateLocale(String language) {
    _locale.value = Locale(language, _getCountryCode(language));
    Get.updateLocale(_locale.value);
    // Logger().d('Locale updated to: ${_locale.value}');
  }

  void refreshLocale() {
    _updateLocale(selectedLanguage.value);
  }

  String? _getCountryCode(String language) {
    switch (language) {
      case 'fr':
        return 'FR';
      case 'en':
        return 'US';
      case 'es':
        return 'ES';
      case 'zh':
        return 'CN';
      case 'bn':
        return 'BD';
      default:
        return null;
    }
  }

  bool _isSupportedLanguage(String language) {
    const supportedLanguages = ['en', 'fr', 'es', 'zh', 'bn'];
    return supportedLanguages.contains(language);
  }
}
