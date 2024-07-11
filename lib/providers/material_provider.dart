import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/app_localizations.dart';
import '../utilities/constants.dart';

class MaterialProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool isLightMode(BuildContext context) {
    if (_themeMode != ThemeMode.system) {
      return _themeMode == ThemeMode.light;
    }

    return MediaQuery.of(context).platformBrightness == Brightness.light;
  }

  Future<String> initProvider() async {
    try {
      debugPrint("(MaterialProvider) Starting initiating");
      _themeMode = await _getThemeMode();
      debugPrint("(MaterialProvider) Ending initiating");
      notifyListeners();
      return 'Completed';
    } catch (e) {
      debugPrint('(MaterialProvider) Error initializing provider: $e');
      return 'Error';
    }
  }

  IconData themeIconData() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.auto_mode_outlined;
    }
  }

  String themeText(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return AppLocalizations.of(context)?.translate('mp_light') ?? 'Light';
      case ThemeMode.dark:
        return AppLocalizations.of(context)?.translate('mp_dark') ?? 'Dark';
      case ThemeMode.system:
        return AppLocalizations.of(context)?.translate('mp_sd') ??
            'System Default';
    }
  }

  Future<void> onSelected(ThemeMode mode) async {
    _themeMode = mode;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      switch (_themeMode) {
        case ThemeMode.light:
          await prefs.setString(Constants.themeKey, Constants.lightThemeValue);
          break;
        case ThemeMode.dark:
          await prefs.setString(Constants.themeKey, Constants.darkThemeValue);
          break;
        case ThemeMode.system:
          await prefs.setString(Constants.themeKey, Constants.autoThemeValue);
          break;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('(MaterialProvider) Error saving theme mode: $e');
    }
  }

  Future<ThemeMode> _getThemeMode() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      String value =
          prefs.getString(Constants.themeKey) ?? Constants.lightThemeValue;
      ThemeMode mode;

      switch (value) {
        case Constants.darkThemeValue:
          mode = ThemeMode.dark;
          break;
        case Constants.autoThemeValue:
          mode = ThemeMode.system;
          break;
        default:
          mode = ThemeMode.light;
      }

      return mode;
    } catch (e) {
      debugPrint('(MaterialProvider) Error getting theme mode: $e');
      return ThemeMode.light;
    }
  }
}
