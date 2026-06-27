import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:usage_stats/usage_stats.dart' hide AppInfo;
import '../../core/providers/wellbeing_provider.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

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
  static const _channel = MethodChannel('com.example.careeros/lockdown');

  Map<String, int> _appLimits = {};
  List<String> _blockedKeywords = [];
  bool _isDataLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBlockingData();
  }

  Future<void> _loadBlockingData() async {
    setState(() => _isDataLoading = true);
    try {
      final dynamic limitsRaw = await _channel.invokeMethod('getAppLimits');
      final List<dynamic>? keywords = await _channel.invokeMethod('getBlockedKeywords');

      if (mounted) {
        setState(() {
          _appLimits = Map<String, int>.from(limitsRaw ?? {});
          _blockedKeywords = List<String>.from(keywords ?? []);
          _isDataLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isDataLoading = false);
    }
  }

  Future<void> _setAppLimit(String packageName, int minutes) async {
    setState(() {
      if (minutes <= 0) _appLimits.remove(packageName);
      else _appLimits[packageName] = minutes;
    });
    await _channel.invokeMethod('setAppLimit', {
      'packageName': packageName,
      'minutes': minutes,
    });
  }

  void _addKeyword(String keyword) async {
    if (keyword.isEmpty) return;
    final newList = List<String>.from(_blockedKeywords);
    final lower = keyword.toLowerCase();
    if (!newList.contains(lower)) {
      newList.add(lower);
      setState(() => _blockedKeywords = newList);
      await _channel.invokeMethod('saveBlockedKeywords', newList);
    }
  }

  void _removeKeyword(String keyword) async {
    final newList = List<String>.from(_blockedKeywords);
    newList.remove(keyword);
    setState(() => _blockedKeywords = newList);
    await _channel.invokeMethod('saveBlockedKeywords', newList);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.refresh(hasUsagePermissionProvider);
      ref.refresh(systemUsageProvider);
      _loadBlockingData();
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
               _loadBlockingData();
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

                    _buildSectionLabel("SOVEREIGN GUARD: APP LIMITS", theme),
                    _buildAppBreakdownList(data, theme),
                    const SizedBox(height: 40),

                    _buildSectionLabel("CONTENT BLOCKER: KEYWORDS", theme),
                    _buildKeywordBlockerSection(theme),
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

  Widget _buildAppBreakdownList(List<UsageInfo> stats, ThemeData theme) {
    final sortedStats = List<UsageInfo>.from(stats)
      ..sort((a, b) => (int.tryParse(b.totalTimeInForeground ?? '0') ?? 0)
          .compareTo(int.tryParse(a.totalTimeInForeground ?? '0') ?? 0));

    // PERFORMANCE: Use ListView.builder for lazy loading instead of mapping to a Column
    return NeumorphicContainer(
      borderRadius: 30,
      depth: 10,
      child: SizedBox(
        height: 500, // Fixed height to enable virtualization
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: sortedStats.take(20).length,
          physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final info = sortedStats[index];
            return _AppLimitTile(
              key: ValueKey(info.packageName),
              info: info,
              currentLimit: _appLimits[info.packageName],
              onSetLimit: (mins) => _setAppLimit(info.packageName!, mins),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeywordBlockerSection(ThemeData theme) {
    final controller = TextEditingController();
    return NeumorphicContainer(
      borderRadius: 30,
      depth: 10,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: NeumorphicContainer(
                  borderRadius: 15,
                  depth: 2,
                  isPressed: true,
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    onSubmitted: (val) {
                       _addKeyword(val);
                       controller.clear();
                    },
                    decoration: InputDecoration(
                      hintText: "Add Restricted Keyword...",
                      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              NeumorphicContainer(
                shape: BoxShape.circle,
                depth: 4,
                child: IconButton(
                  icon: Icon(Icons.add, color: theme.colorScheme.primary),
                  onPressed: () {
                    _addKeyword(controller.text);
                    controller.clear();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _blockedKeywords.map((k) => NeumorphicContainer(
              borderRadius: 12,
              depth: 2,
              baseColor: theme.colorScheme.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(k, style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _removeKeyword(k),
                    child: Icon(Icons.close, size: 14, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, ThemeData theme) {
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

class _AppLimitTile extends ConsumerWidget {
  final UsageInfo info;
  final int? currentLimit;
  final Function(int) onSetLimit;

  const _AppLimitTile({
    super.key,
    required this.info,
    this.currentLimit,
    required this.onSetLimit,
  });

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

        return ListTile(
          onTap: () => _showLimitDialog(context, appName, currentLimit ?? 0, onSetLimit),
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
          subtitle: Row(
            children: [
              Text(timeStr, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 10)),
              if (currentLimit != null) ...[
                const SizedBox(width: 8),
                Text("/ ${currentLimit}m limit", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 10)),
              ]
            ],
          ),
          trailing: Icon(
            currentLimit != null ? Icons.timer_outlined : Icons.timer_off_outlined,
            color: currentLimit != null ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.1),
            size: 18,
          ),
        );
      },
      loading: () => const ListTile(title: Text("...")),
      error: (_, __) => ListTile(title: Text(packageName)),
    );
  }

  void _showLimitDialog(BuildContext context, String appName, int current, Function(int) onSave) {
    int localValue = current == 0 ? 30 : current;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1))),
          title: Text("Daily Limit: $appName", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Set daily usage limit in minutes. App will be blocked once reached.", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   NeumorphicContainer(
                    shape: BoxShape.circle,
                    depth: 4,
                    child: InkWell(
                      onTap: () => setDialogState(() {
                        if (localValue > 15) localValue -= 15;
                      }),
                      child: CircleAvatar(radius: 22, backgroundColor: Colors.transparent, child: Text("-15", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12))),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text("$localValue min", style: TextStyle(color: theme.colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  NeumorphicContainer(
                    shape: BoxShape.circle,
                    depth: 4,
                    child: InkWell(
                      onTap: () => setDialogState(() {
                        localValue += 15;
                      }),
                      child: CircleAvatar(radius: 22, backgroundColor: Colors.transparent, child: Text("+15", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12))),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                onSave(0);
                Navigator.pop(context);
              },
              child: const Text("REMOVE LIMIT", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(localValue);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.black),
              child: const Text("SET LIMIT"),
            ),
          ],
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
          "Today's Screen Time",
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -1.5),
        ).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 4),
        Text(
          "RESETTING EVERY MIDNIGHT • 12:00 AM",
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

    double progress = (totalMinutes / 240.0).clamp(0.0, 1.0);

    return NeumorphicContainer(
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
