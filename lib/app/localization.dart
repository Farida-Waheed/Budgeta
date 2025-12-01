// lib/app/localization.dart
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _DummyLocalizationDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // TODO: connect to real ARB / localization later
  String get appName => 'Budgeta';
}

class _DummyLocalizationDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _DummyLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_DummyLocalizationDelegate old) => false;
}
