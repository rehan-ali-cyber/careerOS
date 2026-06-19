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
import '../../core/theme/glass_theme.dart';
import '../../core/providers/ui_state_provider.dart';
import '../chat/providers/career_pilot_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final stats = ref.watch(statsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.profile.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16, letterSpacing: 3)),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: GlassTheme.waterGradient),
        child: ListView(
          padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 40),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildUserHeader(settings.userName),
            const SizedBox(height: 32),

            _buildSectionLabel("VOYAGE PERFORMANCE"),
            const SizedBox(height: 12),
            _StatsGrid(stats: stats),

            const SizedBox(height: 32),
            _buildSectionLabel("VESSEL HEALTH"),
            const SizedBox(height: 12),
            _VesselHealthCard(apiKey: settings.apiKey),

            const SizedBox(height: 32),
            _buildSectionLabel("COMMAND SETTINGS"),
            const SizedBox(height: 12),
            _GlassProfileCard(
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
            _GlassProfileCard(
              title: 'Career Destination',
              value: settings.targetCareer,
              icon: Icons.explore_outlined,
              onTap: () => _showEditDialog(
                context,
                'Edit Career Goal',
                settings.targetCareer,
                (val) => ref.read(settingsProvider.notifier).updateTargetCareer(val),
              ),
            ),
            const SizedBox(height: 16),
            _GlassProfileCard(
              title: 'AI Intelligence (Gemini API Key)',
              value: settings.apiKey.isEmpty ? 'Not Set (Required for AI)' : _maskApiKey(settings.apiKey),
              icon: Icons.vpn_key_outlined,
              onTap: () => _showEditDialog(
                context,
                'Set Gemini API Key',
                settings.apiKey,
                (val) => ref.read(settingsProvider.notifier).updateApiKey(val),
              ),
            ),
            const SizedBox(height: 16),
            _GlassProfileCard(
              title: 'Vessel Language',
              value: _getLanguageName(settings.languageCode),
              icon: Icons.language_rounded,
              onTap: () => _showLanguagePicker(context, ref, settings.languageCode),
            ),

            const SizedBox(height: 32),
            _buildSectionLabel("ZEN LOYALTY STATUS"),
            const SizedBox(height: 12),
            _ZenLoyaltyCard(breaks: settings.commitmentBreaks),

            const SizedBox(height: 32),
            _buildSectionLabel("MISSION CONTROL"),
            const SizedBox(height: 12),
            _MissionControlCard(),

            const SizedBox(height: 48),
            _ResetDataButton(),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "v1.0.0-PROXIMA",
                style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(String name) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent]),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "V",
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
          ),
          Text(
            "COMMANDER",
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2),
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

  void _showEditDialog(BuildContext context, String title, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF001220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Colors.white10)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white24))),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Vessel state updated successfully"),
                    backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('SAVE', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, String currentCode) {
    ref.read(isNavBarVisibleProvider.notifier).state = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white10),
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
      ),
    ).whenComplete(() {
      ref.read(isNavBarVisibleProvider.notifier).state = true;
    });
  }

  Widget _languageOption(BuildContext context, WidgetRef ref, String code, String name) {
    return ListTile(
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, color: color.withOpacity(0.6), size: 14),
                  const SizedBox(width: 8),
                  Text(label, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
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

    return FutureBuilder<Map<String, dynamic>>(
      future: ai.checkHealth(apiKey),
      builder: (context, snapshot) {
        final health = snapshot.data ?? {'status': 'CHECKING', 'message': 'Checking vessel systems...'};
        final Color color = health['status'] == 'READY' ? Colors.greenAccent : (health['status'] == 'CHECKING' ? Colors.white24 : Colors.redAccent);

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(duration: 1000.ms),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(health['status'].toString(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        const SizedBox(height: 2),
                        Text(health['message'].toString(), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              const _InfoRow(label: "CORE ENGINE", value: "FLUTTER 3.22"),
              Divider(color: Colors.white.withOpacity(0.05), height: 24),
              const _InfoRow(label: "DATA LEDGER", value: "DRIFT SQLITE"),
              Divider(color: Colors.white.withOpacity(0.05), height: 24),
              const _InfoRow(label: "AI MODULE", value: "GEMINI 1.5"),
            ],
          ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ZenLoyaltyCard extends StatelessWidget {
  final int breaks;
  const _ZenLoyaltyCard({required this.breaks});

  @override
  Widget build(BuildContext context) {
    final Color color = breaks == 0 ? Colors.cyanAccent : (breaks < 5 ? Colors.orangeAccent : Colors.redAccent);
    final String status = breaks == 0 ? "STALWART" : (breaks < 5 ? "WAVERING" : "UNSTABLE");

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("COMMITMENT INTEGRITY", style: TextStyle(color: color.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(status, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(breaks == 0 ? Icons.shield_rounded : Icons.gavel_rounded, color: color, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$breaks BROKEN COMMITMENTS",
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          breaks == 0 ? "Your focus is iron-clad." : "Commitment integrity compromised.",
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassProfileCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassProfileCard({required this.title, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: Colors.cyanAccent.withOpacity(0.8), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.1), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetDataButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Colors.redAccent.withOpacity(0.6),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.redAccent.withOpacity(0.1))),
      ),
      onPressed: () => _showResetConfirmation(context, ref),
      icon: const Icon(Icons.dangerous_outlined, size: 20),
      label: const Text('ERASE ALL MISSION DATA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11)),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A0000),
          title: const Text("CRITICAL RESET", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
          content: const Text("This will permanently erase all chat history, roadmaps, and consistency logs. This action is IRREVERSIBLE.",
            style: TextStyle(color: Colors.white70)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Colors.redAccent)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('ABORT', style: TextStyle(color: Colors.white24))),
            TextButton(
              onPressed: () async {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                );

                try {
                  await ref.read(databaseProvider).resetCareerCounseling();
                  await PreferencesService.clearAll();

                  if (context.mounted) {
                    // Close loading indicator and dialog
                    Navigator.of(context).pop(); // Close loader
                    Navigator.of(context).pop(); // Close confirm dialog
                    context.go('/onboarding');
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close loader
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Purge Failed: $e"), backgroundColor: Colors.redAccent),
                    );
                  }
                }
              },
              child: const Text('CONFIRM ERASE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
