import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'strings.dart';

class LocaleProvider extends ChangeNotifier {
  static final LocaleProvider _instance = LocaleProvider._();
  factory LocaleProvider() => _instance;
  LocaleProvider._();

  static const _key = 'app_locale';

  Locale _locale = const Locale('fr');
  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'fr';
    _locale = Locale(code);
    S.setLocale(_locale);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    S.setLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
    notifyListeners();
  }
}
