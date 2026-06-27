import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/app_database.dart';
import 'ai_service.dart';
import 'package:usage_stats/usage_stats.dart';

/// WellbeingService: Monitors system-wide app usage via Android's UsageStatsManager.
class WellbeingService {
  final AppDatabase _db;
  final Ref _ref;
  AppDatabase get db => _db;
  Timer? _syncTimer;

  WellbeingService(this._db, this._ref, AIService _);

  /// Starts the tracking cycles
  void startMonitoring() {
    _syncTimer?.cancel();
    // Sync system usage every 30 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) => getTodayUsage());

    // INITIAL SYNC
    getTodayUsage();
  }

  /// Explicitly query the OS for all apps used today
  Future<Map<String, UsageInfo>> getTodayUsage() async {
    try {
      bool? hasPermission = await UsageStats.checkUsagePermission();
      if (hasPermission != true) return {};

      DateTime now = DateTime.now();
      // Start of day logic: Exactly 12:00 AM Today
      DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);

      if (kDebugMode) {
        debugPrint('Wellbeing: Querying from ${startOfDay.toIso8601String()} to ${now.toIso8601String()}');
      }

      // Use query and aggregate to get total time for each package from midnight until now
      return await UsageStats.queryAndAggregateUsageStats(startOfDay, now);
    } catch (e) {
      if (kDebugMode) debugPrint('Wellbeing: Query Error: $e');
      return {};
    }
  }

  void stopMonitoring() {
    _syncTimer?.cancel();
  }
}
