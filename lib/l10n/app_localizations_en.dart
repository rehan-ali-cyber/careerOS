// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CareerOS';

  @override
  String welcomeBack(String name) {
    return 'Welcome Back, $name 👋';
  }

  @override
  String get todayTargets => 'Today’s Targets';

  @override
  String get chatAssistant => 'AI Career Assistant';

  @override
  String get roadmap => 'Career Roadmap';

  @override
  String get progress => 'My Progress';

  @override
  String get profile => 'Profile';
}
