import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/initialization/app_initializer.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/wellbeing_provider.dart';


Future<void> main() async {
  // RULE 1: Binding initialized before async logic
  WidgetsFlutterBinding.ensureInitialized();

  // RULE 5: Safe initialization with non-nullable fallback
  bool initSuccess = false;
  try {
    initSuccess = await AppInitializer.initialize();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Startup Error: $e');
    }
    initSuccess = false;
  }

  runApp(
    // RULE 3: Global scope wrap exactly once
    ProviderScope(
      child: CareerOS(isInitialized: initSuccess),
    ),
  );
}

class CareerOS extends ConsumerStatefulWidget {
  final bool isInitialized;

  const CareerOS({super.key, required this.isInitialized});

  @override
  ConsumerState<CareerOS> createState() => _CareerOSState();
}

class _CareerOSState extends ConsumerState<CareerOS> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // RULE: Initialize core background services
    if (widget.isInitialized) {
      ref.read(wellbeingServiceProvider);
    }

    // RULE 7: App Stability - Minimal Fallback UI
    if (!widget.isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: Text(
              'Failed to initialize CareerOS. Please restart.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CareerOS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      locale: Locale(settings.languageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('zh'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first; // Fallback to English
      },
    );
  }
}
