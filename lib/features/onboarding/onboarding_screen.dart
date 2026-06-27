import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:permission_handler/permission_handler.dart';
import '../../core/persistence/preferences_service.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/widgets/beautiful_background.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';

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
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();

    // Show restricted settings guide immediately on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRestrictedSettingsDialog(isAuto: true);
    });
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

      // Automatic dismissal if all permissions are granted
      if (usage && dnd && overlay && _isDialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
        _isDialogShowing = false;
      }
    }
  }

  void _showRestrictedSettingsDialog({bool isAuto = false}) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: true, // Always allow clicking outside to close
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
        ),
        title: Row(
          children: [
            const Icon(Icons.security_update_warning_rounded, color: Colors.orangeAccent, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text("Enable App Settings", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Android 13+ restricts permissions for apps installed via APK.",
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 20),
            _stepRow("1", "Click 'OPEN SETTINGS' below"),
            _stepRow("2", "Tap the 3-dots (⋮) at the top right"),
            _stepRow("3", "Select 'Allow restricted settings'"),
            _stepRow("4", "Return to app to enable permissions"),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Required for Zen Mode & Digital Wellbeing.",
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _isDialogShowing = false;
              Navigator.pop(context);
            },
            child: Text("MAYBE LATER", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.38))),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              // Don't close dialog yet, let the lifecycle check handle it or user can close manually
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("OPEN SETTINGS", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((_) => _isDialogShowing = false);
  }

  Widget _stepRow(String number, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
            child: Text(number, style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13))),
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
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _currentStep == 0 ? _buildInfoStep() : _buildPermissionStep(),
        ),
      ),
    );
  }

  Widget _buildInfoStep() {
    final theme = Theme.of(context);
    return Center(
      key: const ValueKey(0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch_rounded, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              "Welcome to CareerOS",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -1),
            ),
            const SizedBox(height: 8),
            Text(
              "Initialize your professional DNA",
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.54), fontSize: 16),
            ),
            const SizedBox(height: 48),
            _buildGlassTextField(_nameController, "Your Name", Icons.person_outline),
            const SizedBox(height: 16),
            _buildGlassTextField(_careerController, "Target Career (e.g. AI Engineer)", Icons.explore_outlined),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: NeumorphicContainer(
                borderRadius: 20,
                baseColor: theme.colorScheme.primary,
                depth: 8,
                child: ElevatedButton(
                  onPressed: _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("NEXT PHASE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStep() {
    final theme = Theme.of(context);
    return Center(
      key: const ValueKey(1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security_rounded, size: 60, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              "System Calibration",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              "Zen Mode and Wellbeing features require specific authorities to protect your focus.",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.54), fontSize: 14),
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
              child: NeumorphicContainer(
                borderRadius: 20,
                depth: 8,
                child: ElevatedButton(
                  onPressed: _finishSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: theme.colorScheme.primary,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("INITIALIZE VESSEL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "You can grant these now or skip and enable them later in settings.",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField(TextEditingController controller, String hint, IconData icon) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 20,
      depth: 4,
      isPressed: true, // Input fields look better debossed (pressed)
      child: TextField(
        controller: controller,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2)),
          prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.38)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeumorphicContainer(
        borderRadius: 16,
        isPressed: isGranted,
        depth: isGranted ? 2 : 8,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  NeumorphicContainer(
                    shape: BoxShape.circle,
                    depth: isGranted ? 2 : 4,
                    isPressed: isGranted,
                    baseColor: isGranted ? Colors.cyanAccent.withOpacity(0.1) : const Color(0xFF1A1A1A),
                    padding: const EdgeInsets.all(10),
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
      ),
    );
  }
}
