import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/preferences_service.dart';

class SettingsState {
  final String userName;
  final String targetCareer;
  final String languageCode;
  final String apiKey;
  final int commitmentBreaks;

  SettingsState({
    required this.userName,
    required this.targetCareer,
    required this.languageCode,
    required this.apiKey,
    required this.commitmentBreaks,
  });

  SettingsState copyWith({
    String? userName,
    String? targetCareer,
    String? languageCode,
    String? apiKey,
    int? commitmentBreaks,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      targetCareer: targetCareer ?? this.targetCareer,
      languageCode: languageCode ?? this.languageCode,
      apiKey: apiKey ?? this.apiKey,
      commitmentBreaks: commitmentBreaks ?? this.commitmentBreaks,
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
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
