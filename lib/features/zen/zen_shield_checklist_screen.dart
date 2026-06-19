import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/permission_card.dart';
import 'providers/zen_provider.dart';
import '../../core/services/lockdown_service.dart';

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

    return Scaffold(
      backgroundColor: Colors.black, // Vantablack minimalism
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white24, size: 30),
          onPressed: () => Navigator.pop(context),
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
                color: Colors.cyanAccent.withOpacity(0.03),
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
                  const Text(
                    "PRE-FLIGHT CHECK",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 12),
                  const Text(
                    "Authorize Shields",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
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
                        style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 9, letterSpacing: 2),
                      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 4.seconds),
                    ),

                  _buildLaunchButton(context, isReadyToDive),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchButton(BuildContext context, bool isReady) {
    return Consumer(
      builder: (context, ref, _) => InkWell(
        onTap: isReady ? () {
          Navigator.pop(context);
          ref.read(zenProvider.notifier).startSanctuary(widget.minutes, widget.task);
        } : null,
        borderRadius: BorderRadius.circular(100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isReady ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.01),
            border: Border.all(
              color: isReady ? Colors.cyanAccent.withOpacity(0.4) : Colors.white.withOpacity(0.05),
              width: 1
            ),
            boxShadow: isReady ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 20)] : [],
          ),
          child: Icon(
            Icons.power_settings_new_rounded,
            color: isReady ? Colors.cyanAccent : Colors.white10,
            size: 32
          ),
        ),
      ),
    ).animate(target: isReady ? 1 : 0).fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8));
  }

  void _showHardwarePinningGuide() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.03),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: const BorderSide(color: Colors.white10)
          ),
          title: const Text(
            "Hardware Lock",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w200, fontSize: 18)
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "1. Open Recents\n2. Tap Icon\n3. Tap PIN",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 13, height: 2, letterSpacing: 1),
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
                child: const Text("CONFIRM", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
