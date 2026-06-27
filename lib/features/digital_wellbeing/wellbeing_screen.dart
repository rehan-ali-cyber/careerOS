import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:usage_stats/usage_stats.dart' hide AppInfo;
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../../core/providers/wellbeing_provider.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';
import 'dart:ui';

String _formatDuration(int minutes) {
  if (minutes < 60) return "${minutes}m";
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? "${h}h" : "${h}h ${m}m";
}

class WellbeingScreen extends ConsumerStatefulWidget {
  const WellbeingScreen({super.key});

  @override
  ConsumerState<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends ConsumerState<WellbeingScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh permissions when user returns from settings
      ref.refresh(hasUsagePermissionProvider);
      ref.refresh(systemUsageProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usageAsync = ref.watch(systemUsageProvider);
    final usagePermissionAsync = ref.watch(hasUsagePermissionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.onSurface.withOpacity(0.24)),
            onPressed: () {
               ref.refresh(systemUsageProvider);
               ref.refresh(hasUsagePermissionProvider);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _Header(),
              const SizedBox(height: 30),

              usagePermissionAsync.when(
                data: (granted) => granted ? const SizedBox.shrink() : _PermissionCard(
                  icon: Icons.security_rounded,
                  title: "Usage Access Required",
                  description: "To audit system-wide screen time, CareerOS needs permission to read usage stats.",
                  onGrant: () => UsageStats.grantUsagePermission(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              usageAsync.when(
                data: (data) => Column(
                  children: [
                    _UsageStatsOverview(stats: data),
                    const SizedBox(height: 40),
                  ],
                ),
                loading: () => const _LoadingStats(),
                error: (e, _) => _ErrorCard(error: e.toString()),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Digital Wellbeing",
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -1.5),
        ).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 4),
        Text(
          "SYSTEM-WIDE COGNITIVE AUDIT",
          style: TextStyle(fontSize: 10, color: theme.colorScheme.primary.withOpacity(0.8), fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Future<void> Function() onGrant;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onGrant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 30,
      depth: 10,
      child: Column(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 32),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
          ),
          const SizedBox(height: 24),
          NeumorphicContainer(
            borderRadius: 15,
            depth: 4,
            baseColor: theme.colorScheme.primary.withOpacity(0.1),
            child: ElevatedButton(
              onPressed: () async {
                await onGrant();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text("GRANT ACCESS"),
            ),
          ),
        ],
      ),
    ).animate().shake();
  }
}

class _UsageStatsOverview extends StatelessWidget {
  final List<UsageInfo> stats;
  const _UsageStatsOverview({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int totalMinutes = stats.fold(0, (sum, info) {
      final ms = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
      return sum + (ms ~/ 60000);
    });

    // Goal: 4 hours (240 mins) or dynamic
    double progress = (totalMinutes / 240.0).clamp(0.0, 1.0);

    return Column(
      children: [
        NeumorphicContainer(
          padding: const EdgeInsets.symmetric(vertical: 40),
          borderRadius: 30,
          depth: 10,
          child: Column(
            children: [
              SizedBox(
                height: 180,
                width: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 4,
                      color: theme.colorScheme.onSurface.withOpacity(0.05),
                    ),
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      color: progress > 0.8 ? Colors.orangeAccent : theme.colorScheme.primary,
                    ).animate().rotate(duration: 1.seconds, begin: -0.5, end: 0),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDuration(totalMinutes),
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
                          ),
                          Text(
                            "SCREEN TIME",
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.38), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "TOTAL COGNITIVE LOAD TODAY",
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.24), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const _SectionLabel(label: "APPLICATION BREAKDOWN"),
        NeumorphicContainer(
          padding: const EdgeInsets.symmetric(vertical: 12),
          borderRadius: 30,
          depth: 10,
          child: Column(
            children: List.generate(stats.take(15).length, (index) {
              final info = stats[index];
              return _AppUsageTile(info: info)
                .animate(delay: (index * 100).ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1);
            }),
          ),
        ),
      ],
    );
  }
}

class _AppUsageTile extends ConsumerWidget {
  final UsageInfo info;
  const _AppUsageTile({required this.info});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ms = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
    final mins = ms ~/ 60000;
    final packageName = info.packageName ?? "Unknown";
    final timeStr = _formatDuration(mins);
    final theme = Theme.of(context);

    final metadataAsync = ref.watch(appMetadataProvider(packageName));

    return metadataAsync.when(
      data: (app) {
        String appName = app?.name ?? packageName.split('.').last.toUpperCase();
        Widget icon = app?.icon != null
          ? Image.memory(app!.icon!, width: 24, height: 24)
          : Icon(Icons.android_rounded, color: theme.colorScheme.onSurface.withOpacity(0.24), size: 16);

        return Column(
          children: [
            ListTile(
              leading: NeumorphicContainer(
                shape: BoxShape.circle,
                depth: 2,
                isPressed: true,
                padding: const EdgeInsets.all(8),
                child: icon,
              ),
              title: Text(appName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              subtitle: Text(
                packageName,
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.24), fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                timeStr,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const ListTile(
        leading: CircularProgressIndicator(strokeWidth: 1),
        title: Text("Loading..."),
      ),
      error: (_, __) => ListTile(
        title: Text(packageName),
        trailing: Text(timeStr),
      ),
    );
  }
}

class _LoadingStats extends StatelessWidget {
  const _LoadingStats();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      padding: const EdgeInsets.all(40),
      borderRadius: 30,
      depth: 6,
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text("QUERYING SYSTEM LEDGER...", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.24), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  const _ErrorCard({required this.error});
  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 30,
      depth: 6,
      child: Text("Error fetching stats: $error", style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.2),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2
        ),
      ),
    );
  }
}
