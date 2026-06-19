import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class PreferencesService {
  static const String _boxName = 'settings';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _userNameKey = 'user_name';
  static const String _targetCareerKey = 'target_career';
  static const String _languageKey = 'language_code';
  static const String _apiKeyKey = 'api_key';
  static const String _commitmentBreaksKey = 'commitment_breaks';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static bool isOnboardingCompleted() {
    final box = Hive.box(_boxName);
    return box.get(_onboardingKey, defaultValue: false);
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    final box = Hive.box(_boxName);
    await box.put(_onboardingKey, value);
  }

  static String getUserName() {
    final box = Hive.box(_boxName);
    return box.get(_userNameKey, defaultValue: '');
  }

  static Future<void> setUserName(String name) async {
    final box = Hive.box(_boxName);
    await box.put(_userNameKey, name);
  }

  static String getTargetCareer() {
    final box = Hive.box(_boxName);
    return box.get(_targetCareerKey, defaultValue: '');
  }

  static Future<void> setTargetCareer(String career) async {
    final box = Hive.box(_boxName);
    await box.put(_targetCareerKey, career);
  }

  static String getLanguageCode() {
    final box = Hive.box(_boxName);
    return box.get(_languageKey, defaultValue: 'en');
  }

  static Future<void> setLanguageCode(String code) async {
    final box = Hive.box(_boxName);
    await box.put(_languageKey, code);
  }

  static String getApiKey() {
    final box = Hive.box(_boxName);
    return box.get(_apiKeyKey, defaultValue: '');
  }

  static Future<void> setApiKey(String key) async {
    final box = Hive.box(_boxName);
    await box.put(_apiKeyKey, key);
  }

  static int getCommitmentBreaks() {
    final box = Hive.box(_boxName);
    return box.get(_commitmentBreaksKey, defaultValue: 0);
  }

  static Future<void> setCommitmentBreaks(int count) async {
    final box = Hive.box(_boxName);
    await box.put(_commitmentBreaksKey, count);
  }

  static Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.clear();
  }
}
