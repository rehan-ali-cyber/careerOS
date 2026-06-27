import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/zen_provider.dart';
import '../../core/services/lockdown_service.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';

/**
 * ZenSanctuaryScreen is the core focus environment.
 * It features a dark, calming palette, a pulse-based oxygen timer,
 * and persistent background ambient animations.
 */
class ZenSanctuaryScreen extends ConsumerStatefulWidget {
  const ZenSanctuaryScreen({super.key});

  @override
  ConsumerState<ZenSanctuaryScreen> createState() => _ZenSanctuaryScreenState();
}

class _ZenSanctuaryScreenState extends ConsumerState<ZenSanctuaryScreen> {
  @override
  void initState() {
    super.initState();
    // Engage physical lockdown on entry
    LockdownService.startLockdown();
    LockdownService.hijackAudio();
  }

  @override
  void dispose() {
    // Release locks on exit
    LockdownService.stopLockdown();
    LockdownService.releaseAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zen = ref.watch(zenProvider);

    // Timer formatting
    final minutes = (zen.remainingSeconds / 60).floor();
    final seconds = zen.remainingSeconds % 60;
    final timeStr = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    return PopScope(
      canPop: !zen.isLocked, // THE VIRTUAL CAGE: Prevent system back gestures
      onPopInvoked: (didPop) => _handleSystemBack(context, didPop),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: _sanctuaryBackground(),
          child: Stack(
            children: [
              // AMBIENCE: Slow drifting deep-sea bubbles
              ...List.generate(5, (i) => _AmbientDriftBubble(index: i)),

              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCurrentTaskBadge(zen.focusTask),
                      const SizedBox(height: 60),
                      _buildOxygenTimer(context, zen, timeStr),
                      const SizedBox(height: 80),
                      _buildActionFooter(ref, zen),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // UI COMPONENTS
  // ────────────────────────────────────────────────────────────

  BoxDecoration _sanctuaryBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF001025), // Absolute Deep Blue
          Color(0xFF000000), // Vantablack Depth
        ],
      ),
    );
  }

  Widget _buildCurrentTaskBadge(String? task) {
    if (task == null) return const SizedBox.shrink();
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      borderRadius: 20,
      depth: 4,
      child: Text(
        "CURRENT MANEUVER: ${task.toUpperCase()}",
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 2
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2);
  }

  Widget _buildOxygenTimer(BuildContext context, ZenState zen, String timeStr) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // THE CORE BUBBLE
        NeumorphicContainer(
          shape: BoxShape.circle,
          depth: 15,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: Colors.white.withOpacity(0.02)),
            ),
          ),
        ),

        // TIME METRICS
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeStr,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w100,
                color: Colors.white,
                letterSpacing: 3
              ),
            ),
            Text(
              zen.isBreathingBreak ? "RECOVERY PHASE" : "VOYAGE FOCUS",
              style: TextStyle(
                color: Colors.white.withOpacity(0.2),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 5
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionFooter(WidgetRef ref, ZenState zen) {
    if (zen.remainingSeconds <= 0) {
      return _SurfaceExitButton(
        onPressed: () => ref.read(zenProvider.notifier).stopSanctuary()
      ).animate().scale().shimmer();
    }

    return Column(
      children: [
        const Text(
          "IRON-CLAD LOCK ENGAGED",
          style: TextStyle(
            color: Colors.white24,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 3
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds, color: Colors.cyanAccent.withOpacity(0.2)),
        const SizedBox(height: 8),
        Text(
          "THE SEA IS CALM. STAY FOCUSED.",
          style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 9),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  // LOGIC HANDLERS
  // ────────────────────────────────────────────────────────────

  void _handleSystemBack(BuildContext context, bool didPop) {
    if (!didPop) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sanctuary Lock is Active. Complete your mission first."),
          backgroundColor: Color(0xFF001F3F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _ZenCoreBubble extends StatelessWidget {
  final bool isBreathing;
  const _ZenCoreBubble({required this.isBreathing});

  @override
  Widget build(BuildContext context) {
    final activeColor = isBreathing ? Colors.greenAccent : Colors.cyanAccent;

    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: activeColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: activeColor.withOpacity(0.08), blurRadius: 50, spreadRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(110),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.white.withOpacity(0.02)),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .moveY(begin: -8, end: 8, duration: 4.seconds, curve: Curves.easeInOutSine);
  }
}

class _AmbientDriftBubble extends StatelessWidget {
  final int index;
  const _AmbientDriftBubble({required this.index});

  @override
  Widget build(BuildContext context) {
    final rand = Random(index);
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: -150,
      left: rand.nextDouble() * screenWidth,
      child: Container(
        width: rand.nextDouble() * 50 + 20,
        height: rand.nextDouble() * 50 + 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.02),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
      ).animate(onPlay: (c) => c.repeat())
       .moveY(begin: 0, end: -1200, duration: (rand.nextInt(15) + 15).seconds)
       .fadeOut(),
    );
  }
}

class _SurfaceExitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SurfaceExitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: 32,
      depth: 10,
      baseColor: Colors.cyanAccent,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        onPressed: onPressed,
        child: const Text(
          "SURFACE VOYAGE",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)
        ),
      ),
    );
  }
}
