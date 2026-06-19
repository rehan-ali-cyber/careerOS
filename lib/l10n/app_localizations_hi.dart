// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'कैरियरओएस';

  @override
  String welcomeBack(String name) {
    return 'वापसी पर स्वागत है, $name 👋';
  }

  @override
  String get todayTargets => 'आज के लक्ष्य';

  @override
  String get chatAssistant => 'एआई कैरियर सहायक';

  @override
  String get roadmap => 'कैरियर रोडमैप';

  @override
  String get progress => 'मेरी प्रगति';

  @override
  String get profile => 'प्रोफ़ाइल';
}
