import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/persistence/preferences_service.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/beautiful_background.dart';

import '../../core/services/lockdown_service.dart';
import 'package:usage_stats/usage_stats.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with WidgetsBindingObserver {
  final _nameController = TextEditingController();
  final _careerController = TextEditingController();
  int _currentStep = 0;

  bool _hasUsage = false;
  bool _hasDnd = false;
  bool _hasOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _careerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final usage = await UsageStats.checkUsagePermission() ?? false;
    final dnd = await LockdownService.hasDndAccess();
    final overlay = await LockdownService.hasOverlayAccess();
    if (mounted) {
      setState(() {
        _hasUsage = usage;
        _hasDnd = dnd;
        _hasOverlay = overlay;
      });
    }
  }

  void _showRestrictedSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Text("Enable Settings", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Android 13+ requires an extra step for APK installs:",
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text("1. Go to Phone Settings > Apps", style: TextStyle(color: Colors.white60)),
            Text("2. Select 'careerOS'", style: TextStyle(color: Colors.white60)),
            Text("3. Tap (⋮) in the top right corner", style: TextStyle(color: Colors.white60)),
            Text("4. Tap 'Allow restricted settings'", style: TextStyle(color: Colors.white60)),
            SizedBox(height: 15),
            Text("After this, you can enable these permissions.", style: TextStyle(color: Colors.cyanAccent, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("I UNDERSTAND", style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final name = _nameController.text.trim();
    final career = _careerController.text.trim();

    if (name.isEmpty || career.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both your name and target career")),
      );
      return;
    }

    await ref.read(settingsProvider.notifier).updateUserName(name);
    await ref.read(settingsProvider.notifier).updateTargetCareer(career);

    setState(() => _currentStep = 1);
  }

  Future<void> _finishSetup() async {
    await PreferencesService.setOnboardingCompleted(true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: BeautifulBackground()),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _currentStep == 0 ? _buildInfoStep() : _buildPermissionStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep() {
    return Center(
      key: const ValueKey(0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch_rounded, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 24),
            const Text(
              "Welcome to CareerOS",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
            ),
            const SizedBox(height: 8),
            const Text(
              "Initialize your professional DNA",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 48),
            _buildGlassTextField(_nameController, "Your Name", Icons.person_outline),
            const SizedBox(height: 16),
            _buildGlassTextField(_careerController, "Target Career (e.g. AI Engineer)", Icons.explore_outlined),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text("NEXT PHASE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStep() {
    return Center(
      key: const ValueKey(1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security_rounded, size: 60, color: Colors.cyanAccent),
            const SizedBox(height: 24),
            const Text(
              "System Calibration",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              "Zen Mode and Wellbeing features require specific authorities to protect your focus.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 40),
            _PermissionTile(
              title: "Usage Stats",
              subtitle: "Tracks focus metrics",
              icon: Icons.bar_chart_rounded,
              isGranted: _hasUsage,
              onTap: () async {
                await UsageStats.grantUsagePermission();
                _showRestrictedSettingsDialog();
              },
            ),
            _PermissionTile(
              title: "Do Not Disturb",
              subtitle: "Silences notifications",
              icon: Icons.do_not_disturb_on_rounded,
              isGranted: _hasDnd,
              onTap: () async {
                await LockdownService.requestDndAccess();
                _showRestrictedSettingsDialog();
              },
            ),
            _PermissionTile(
              title: "System Overlay",
              subtitle: "Enforces focus lock",
              icon: Icons.layers_rounded,
              isGranted: _hasOverlay,
              onTap: () async {
                await LockdownService.requestOverlayAccess();
                _showRestrictedSettingsDialog();
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _finishSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("INITIALIZE VESSEL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "You can grant these now or skip and enable them later in settings.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField(TextEditingController controller, String hint, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
              prefixIcon: Icon(icon, color: Colors.white38),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isGranted;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isGranted ? Colors.cyanAccent.withOpacity(0.05) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isGranted ? Colors.cyanAccent.withOpacity(0.3) : Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isGranted ? Colors.cyanAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: isGranted ? Colors.cyanAccent : Colors.white24, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (isGranted)
                  const Icon(Icons.check_circle_rounded, color: Colors.cyanAccent, size: 20)
                else
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
