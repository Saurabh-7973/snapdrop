import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class LanguageManager {
  static Future<void> setLocale(BuildContext context, Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    // Restart the app by rebuilding MaterialApp
    MyApp.setLocale(context, locale);
  }

  static Future<Locale> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    return Locale(languageCode ?? 'en'); // Default to English
  }
}
