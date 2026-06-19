// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '职业系统';

  @override
  String welcomeBack(String name) {
    return '欢迎回来, $name 👋';
  }

  @override
  String get todayTargets => '今日目标';

  @override
  String get chatAssistant => 'AI 职业助手';

  @override
  String get roadmap => '职业路线图';

  @override
  String get progress => '我的进度';

  @override
  String get profile => '个人资料';
}
