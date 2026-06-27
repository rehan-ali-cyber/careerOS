import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/preferences_service.dart';

class SettingsState {
  final String userName;
  final String targetCareer;
  final String languageCode;
  final String apiKey;
  final int commitmentBreaks;
  final bool isDarkMode;

  SettingsState({
    required this.userName,
    required this.targetCareer,
    required this.languageCode,
    required this.apiKey,
    required this.commitmentBreaks,
    required this.isDarkMode,
  });

  SettingsState copyWith({
    String? userName,
    String? targetCareer,
    String? languageCode,
    String? apiKey,
    int? commitmentBreaks,
    bool? isDarkMode,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      targetCareer: targetCareer ?? this.targetCareer,
      languageCode: languageCode ?? this.languageCode,
      apiKey: apiKey ?? this.apiKey,
      commitmentBreaks: commitmentBreaks ?? this.commitmentBreaks,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(SettingsState(
          userName: PreferencesService.getUserName(),
          targetCareer: PreferencesService.getTargetCareer(),
          languageCode: PreferencesService.getLanguageCode(),
          apiKey: PreferencesService.getApiKey(),
          commitmentBreaks: PreferencesService.getCommitmentBreaks(),
          isDarkMode: PreferencesService.isDarkMode(),
        ));

  Future<void> updateUserName(String name) async {
    await PreferencesService.setUserName(name);
    state = state.copyWith(userName: name);
  }

  Future<void> updateTargetCareer(String career) async {
    await PreferencesService.setTargetCareer(career);
    state = state.copyWith(targetCareer: career);
  }

  Future<void> updateLanguage(String code) async {
    await PreferencesService.setLanguageCode(code);
    state = state.copyWith(languageCode: code);
  }

  Future<void> updateApiKey(String key) async {
    await PreferencesService.setApiKey(key);
    state = state.copyWith(apiKey: key);
  }

  Future<void> incrementCommitmentBreaks() async {
    final newCount = state.commitmentBreaks + 1;
    await PreferencesService.setCommitmentBreaks(newCount);
    state = state.copyWith(commitmentBreaks: newCount);
  }

  void toggleTheme() {
    final newValue = !state.isDarkMode;
    PreferencesService.setIsDarkMode(newValue);
    state = state.copyWith(isDarkMode: newValue);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
