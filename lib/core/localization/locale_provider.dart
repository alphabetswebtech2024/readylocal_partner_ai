import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/generated/app_localizations.dart';

export '../../l10n/generated/app_localizations.dart';

/// Holds the app language (English or Telugu) and remembers the choice in
/// SharedPreferences. Only display text changes with the language; values
/// sent to the server stay as they were.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider() {
    L10n._provider = this;
  }

  static const _prefsKey = 'app_language';
  static const supported = [Locale('en'), Locale('te')];

  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  bool get isTelugu => _locale.languageCode == 'te';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && supported.any((l) => l.languageCode == code)) {
      _locale = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}

/// Strings for code that has no BuildContext (snackbars, notifications).
class L10n {
  L10n._();

  static LocaleProvider? _provider;

  static AppLocalizations get current =>
      lookupAppLocalizations(_provider?.locale ?? const Locale('en'));
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
