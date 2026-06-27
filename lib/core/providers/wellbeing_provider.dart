import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/wellbeing_service.dart';
import 'database_provider.dart';
import 'package:usage_stats/usage_stats.dart' hide AppInfo;
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../../features/chat/providers/career_pilot_provider.dart';
import '../persistence/app_database.dart';

/**
 * wellbeingServiceProvider: Provides the singleton instance of WellbeingService.
 */
final wellbeingServiceProvider = Provider<WellbeingService>((ref) {
  final db = ref.watch(databaseProvider);
  final ai = ref.watch(aiServiceProvider);
  final service = WellbeingService(db, ref, ai);
  service.startMonitoring();
  ref.onDispose(() => service.stopMonitoring());
  return service;
});

/**
 * systemUsageProvider: Fetches and sorts today's system usage stats.
 */
final systemUsageProvider = FutureProvider<List<UsageInfo>>((ref) async {
  final service = ref.watch(wellbeingServiceProvider);
  final usageMap = await service.getTodayUsage();

  final list = usageMap.values.where((info) {
    final time = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
    return time > 1000; // Only show apps used for > 1 second
  }).toList();

  // Sort by usage time descending
  list.sort((a, b) {
    final timeA = int.tryParse(a.totalTimeInForeground ?? '0') ?? 0;
    final timeB = int.tryParse(b.totalTimeInForeground ?? '0') ?? 0;
    return timeB.compareTo(timeA);
  });

  return list;
});

/**
 * hasUsagePermissionProvider: Tracks if the user has granted Usage Access.
 */
final hasUsagePermissionProvider = FutureProvider<bool>((ref) async {
  return await UsageStats.checkUsagePermission() ?? false;
});

/**
 * appMetadataProvider: Caches app names and icons.
 */
final appMetadataProvider = FutureProvider.family<AppInfo?, String>((ref, packageName) async {
  // Use simple caching logic
  return await ref.watch(_appMetadataCacheProvider(packageName).future);
});

final _appMetadataCacheProvider = FutureProvider.family<AppInfo?, String>((ref, packageName) async {
  try {
    return await InstalledApps.getAppInfo(packageName);
  } catch (_) {
    return null;
  }
});

