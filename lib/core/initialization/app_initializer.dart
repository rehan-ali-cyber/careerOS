import 'package:flutter/foundation.dart';
import '../persistence/preferences_service.dart';

class AppInitializer {
  /// Entry point for all critical async initialization
  /// Returns true if all essential services started successfully
  static Future<bool> initialize() async {
    bool success = true;

    try {
      // 1. Initialize Key-Value Persistence (Hive)
      await PreferencesService.init();

      // 2. Add other core service initializations here as needed
      // (Database is lazily initialized via Riverpod, but can be pre-warmed if required)

    } catch (e) {
      if (kDebugMode) {
        debugPrint('PRODUCTION INITIALIZATION CRITICAL ERROR: $e');
      }
      success = false;
    }

    return success;
  }
}
