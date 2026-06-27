import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/permission_card.dart';
import 'providers/zen_provider.dart';
import '../../core/services/lockdown_service.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';

/**
 * Redesigned ZenShieldChecklistScreen: Minimalist & Calming.
 * Reduces visual noise and uses subtle color tones to prepare for deep focus.
 */
class ZenShieldChecklistScreen extends StatefulWidget {
  final int minutes;
  final String? task;
  const ZenShieldChecklistScreen({super.key, required this.minutes, this.task});

  @override
  State<ZenShieldChecklistScreen> createState() => _ZenShieldChecklistScreenState();
}

class _ZenShieldChecklistScreenState extends State<ZenShieldChecklistScreen> with WidgetsBindingObserver {

  bool _dndGranted = false;
  bool _overlayGranted = false;
  bool _pinningConfirmed = false;
  bool _deviceOwnerActive = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _verifyAllShields();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) => _verifyAllShields());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifyAllShields();
    }
  }

  Future<void> _verifyAllShields() async {
    final dnd = await LockdownService.hasDndAccess();
    final overlay = await LockdownService.hasOverlayAccess();
    final owner = await LockdownService.isDeviceOwner();

    if (mounted) {
      setState(() {
        _dndGranted = dnd;
        _overlayGranted = overlay;
        _deviceOwnerActive = owner;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReadyToDive = _dndGranted && _overlayGranted && (_deviceOwnerActive || _pinningConfirmed);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeumorphicContainer(
            shape: BoxShape.circle,
            depth: 4,
            child: IconButton(
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.onSurface, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Subtle distant glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.03),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 10.seconds),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "PRE-FLIGHT CHECK",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.38),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 12),
                  Text(
                    "Authorize Shields",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w200,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 1
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 60),

                  PermissionCard(
                    title: "Silence Protocol",
                    description: "NOTIFICATION DEFENSE",
                    icon: Icons.notifications_none_rounded,
                    isGranted: _dndGranted,
                    onGrant: () => LockdownService.requestDndAccess(),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05),

                  PermissionCard(
                    title: "Iron Wall",
                    description: "INTERRUPTION SHIELD",
                    icon: Icons.fullscreen_rounded,
                    isGranted: _overlayGranted,
                    onGrant: () => LockdownService.requestOverlayAccess(),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05),

                  PermissionCard(
                    title: _deviceOwnerActive ? "Sovereign Control" : "Hull Lock",
                    description: "HARDWARE LOCKDOWN",
                    icon: Icons.lock_outline_rounded,
                    isGranted: _deviceOwnerActive || _pinningConfirmed,
                    onGrant: _deviceOwnerActive ? () {} : () => _showHardwarePinningGuide(),
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.05),

                  const Spacer(),

                  if (!isReadyToDive)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        "SYSTEMS STANDBY",
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.1), fontSize: 9, letterSpacing: 2),
                      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 4.seconds),
                    ),

                  _buildLaunchButton(context, isReadyToDive, theme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchButton(BuildContext context, bool isReady, ThemeData theme) {
    return Consumer(
      builder: (context, ref, _) => NeumorphicContainer(
        shape: BoxShape.circle,
        depth: isReady ? 10 : 4,
        isPressed: !isReady,
        baseColor: isReady ? theme.colorScheme.primary : theme.scaffoldBackgroundColor,
        child: InkWell(
          onTap: isReady ? () {
            Navigator.pop(context);
            ref.read(zenProvider.notifier).startSanctuary(widget.minutes, widget.task);
          } : null,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 80,
            height: 80,
            child: Icon(
              Icons.power_settings_new_rounded,
              color: isReady
                  ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                  : theme.colorScheme.onSurface.withOpacity(0.1),
              size: 32
            ),
          ),
        ),
      ),
    ).animate(target: isReady ? 1 : 0).fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8));
  }

  void _showHardwarePinningGuide() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1))
        ),
        title: Text(
          "Hardware Lock",
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w200, fontSize: 18)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "1. Open Recents\n2. Tap Icon\n3. Tap PIN",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.38), fontSize: 13, height: 2, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _pinningConfirmed = true);
              },
              child: Text("CONFIRM", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}
