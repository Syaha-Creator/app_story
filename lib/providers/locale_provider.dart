import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/helper/localization_setup.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = LocalizationSetup.enLocale;
  static const String localeKey = 'app_locale';

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(localeKey);
    if (savedLocale != null) {
      for (var locale in LocalizationSetup.supportedLocales) {
        if (locale.languageCode == savedLocale) {
          _locale = locale;
          notifyListeners();
          break;
        }
      }
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!LocalizationSetup.supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localeKey, locale.languageCode);
  }

  Future<void> clearLocale() async {
    _locale = LocalizationSetup.enLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(localeKey);
  }
}
