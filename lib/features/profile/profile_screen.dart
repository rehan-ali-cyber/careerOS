import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/stats_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/persistence/preferences_service.dart';
import '../../core/services/ai_service.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';
import '../../core/providers/ui_state_provider.dart';
import '../chat/providers/career_pilot_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final stats = ref.watch(statsProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.profile.toUpperCase(),
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                letterSpacing: 3)),
      ),
      body: ListView(
        padding:
            const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 40),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildUserHeader(settings.userName, theme),
          const SizedBox(height: 32),
          _buildSectionLabel("VOYAGE PERFORMANCE", theme),
          const SizedBox(height: 12),
          _StatsGrid(stats: stats),
          const SizedBox(height: 32),
          _buildSectionLabel("VESSEL HEALTH", theme),
          const SizedBox(height: 12),
          _VesselHealthCard(apiKey: settings.apiKey),
          const SizedBox(height: 32),
          _buildSectionLabel("COMMAND SETTINGS", theme),
          const SizedBox(height: 12),
          _NeumorphicProfileCard(
            title: 'Sailor Name',
            value: settings.userName,
            icon: Icons.person_outline_rounded,
            onTap: () => _showEditDialog(
              context,
              'Edit Name',
              settings.userName,
              (val) => ref.read(settingsProvider.notifier).updateUserName(val),
            ),
          ),
          const SizedBox(height: 16),
          _NeumorphicProfileCard(
            title: 'Career Destination',
            value: settings.targetCareer,
            icon: Icons.explore_outlined,
            onTap: () => _showEditDialog(
              context,
              'Edit Career Goal',
              settings.targetCareer,
              (val) =>
                  ref.read(settingsProvider.notifier).updateTargetCareer(val),
            ),
          ),
          const SizedBox(height: 16),
          _NeumorphicProfileCard(
            title: 'AI Intelligence (Gemini API Key)',
            value: settings.apiKey.isEmpty
                ? 'Not Set (Required for AI)'
                : _maskApiKey(settings.apiKey),
            icon: Icons.vpn_key_outlined,
            onTap: () => _showEditDialog(
              context,
              'Set Gemini API Key',
              settings.apiKey,
              (val) => ref.read(settingsProvider.notifier).updateApiKey(val),
            ),
          ),
          const SizedBox(height: 16),
          _NeumorphicProfileCard(
            title: 'Vessel Language',
            value: _getLanguageName(settings.languageCode),
            icon: Icons.language_rounded,
            onTap: () =>
                _showLanguagePicker(context, ref, settings.languageCode),
          ),
          const SizedBox(height: 32),
          _buildSectionLabel("ZEN LOYALTY STATUS", theme),
          const SizedBox(height: 12),
          _ZenLoyaltyCard(breaks: settings.commitmentBreaks),
          const SizedBox(height: 32),
          _buildSectionLabel("MISSION CONTROL", theme),
          const SizedBox(height: 12),
          _MissionControlCard(),
          const SizedBox(height: 48),
          _ResetDataButton(),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "v1.0.0-PROXIMA",
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(String name, ThemeData theme) {
    return Center(
      child: Column(
        children: [
          NeumorphicContainer(
            shape: BoxShape.circle,
            depth: 12,
            padding: const EdgeInsets.all(4),
            baseColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, Colors.blueAccent]),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.scaffoldBackgroundColor,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "V",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface),
                ),
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5),
          ),
          Text(
            "COMMANDER",
            style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, ThemeData theme) {
    return Text(
      label,
      style: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.2),
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 2),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'hi': return 'Hindi (हिन्दी)';
      case 'zh': return 'Chinese (中文)';
      default: return 'English';
    }
  }

  String _maskApiKey(String key) {
    if (key.length <= 8) return '****';
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }

  void _showEditDialog(BuildContext context, String title, String initialValue,
      Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1))),
        title: Text(title,
            style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1))),
            focusedBorder: BorderSide(color: theme.colorScheme.primary) is BorderSide ? UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)) : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.3)))),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Vessel state updated successfully"),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('SAVE',
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(
      BuildContext context, WidgetRef ref, String currentCode) {
    ref.read(isNavBarVisibleProvider.notifier).state = false;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption(context, ref, 'en', 'English'),
              _languageOption(context, ref, 'hi', 'Hindi (हिन्दी)'),
              _languageOption(context, ref, 'zh', 'Chinese (中文)'),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      ref.read(isNavBarVisibleProvider.notifier).state = true;
    });
  }

  Widget _languageOption(
      BuildContext context, WidgetRef ref, String code, String name) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(name,
          style: TextStyle(
              color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
      onTap: () {
        ref.read(settingsProvider.notifier).updateLanguage(code);
        Navigator.pop(context);
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final UserStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(label: "CURRENT STREAK", value: "${stats.currentStreak} DAYS", icon: Icons.bolt_rounded, color: Colors.amberAccent),
        _StatCard(label: "READINESS", value: "${(stats.careerReadiness * 100).toInt()}%", icon: Icons.radar_rounded, color: Colors.cyanAccent),
        _StatCard(label: "LEGS CLEARED", value: "${stats.completedSteps}", icon: Icons.verified_rounded, color: Colors.greenAccent),
        _StatCard(label: "ACTIVE VOYAGES", value: "${stats.activeRoadmaps}", icon: Icons.route_rounded, color: Colors.blueAccent),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 24,
      depth: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color.withOpacity(0.6), size: 14),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    ).animate().fadeIn().scale(delay: 200.ms);
  }
}

class _VesselHealthCard extends ConsumerWidget {
  final String apiKey;
  const _VesselHealthCard({required this.apiKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ai = ref.watch(aiServiceProvider);
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: ai.checkHealth(apiKey),
      builder: (context, snapshot) {
        final health = snapshot.data ??
            {'status': 'CHECKING', 'message': 'Checking vessel systems...'};
        final Color color = health['status'] == 'READY'
            ? Colors.greenAccent
            : (health['status'] == 'CHECKING'
                ? theme.colorScheme.onSurface.withOpacity(0.24)
                : Colors.redAccent);

        return NeumorphicContainer(
          borderRadius: 24,
          depth: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2)
                    ],
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .fade(duration: 1000.ms),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(health['status'].toString(),
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                      const SizedBox(height: 2),
                      Text(health['message'].toString(),
                          style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MissionControlCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 24,
      depth: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const _InfoRow(label: "CORE ENGINE", value: "FLUTTER 3.22"),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.05), height: 24),
            const _InfoRow(label: "DATA LEDGER", value: "DRIFT SQLITE"),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.05), height: 24),
            const _InfoRow(label: "AI MODULE", value: "GEMINI 1.5"),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        Text(value,
            style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ZenLoyaltyCard extends StatelessWidget {
  final int breaks;
  const _ZenLoyaltyCard({required this.breaks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color = breaks == 0
        ? theme.colorScheme.primary
        : (breaks < 5 ? Colors.orangeAccent : Colors.redAccent);
    final String status =
        breaks == 0 ? "STALWART" : (breaks < 5 ? "WAVERING" : "UNSTABLE");

    return NeumorphicContainer(
      borderRadius: 24,
      depth: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("COMMITMENT INTEGRITY",
                    style: TextStyle(
                        color: color.withOpacity(0.5),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(status,
                      style: TextStyle(
                          color: color,
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(breaks == 0 ? Icons.shield_rounded : Icons.gavel_rounded,
                    color: color, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$breaks BROKEN COMMITMENTS",
                        style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        breaks == 0
                            ? "Your focus is iron-clad."
                            : "Commitment integrity compromised.",
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NeumorphicProfileCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _NeumorphicProfileCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 24,
      depth: 6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              NeumorphicContainer(
                padding: const EdgeInsets.all(10),
                borderRadius: 12,
                depth: 2,
                baseColor: theme.colorScheme.primary.withOpacity(0.05),
                child: Icon(icon,
                    color: theme.colorScheme.primary.withOpacity(0.8), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.1), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetDataButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NeumorphicContainer(
      borderRadius: 24,
      depth: 4,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.redAccent.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        onPressed: () => _showResetConfirmation(context, ref),
        icon: const Icon(Icons.dangerous_outlined, size: 20),
        label: const Text('ERASE ALL MISSION DATA',
            style: TextStyle(
                fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11)),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0000),
        title: const Text("CRITICAL RESET",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
        content: const Text(
            "This will permanently erase all chat history, roadmaps, and consistency logs. This action is IRREVERSIBLE.",
            style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Colors.redAccent)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ABORT', style: TextStyle(color: Colors.white24))),
          TextButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
              );

              try {
                await ref.read(databaseProvider).resetCareerCounseling();
                await PreferencesService.clearAll();

                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  context.go('/onboarding');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Purge Failed: $e"),
                        backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text('CONFIRM ERASE',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
