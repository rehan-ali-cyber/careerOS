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
    final theme = Theme.of(context);

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
          decoration: _sanctuaryBackground(theme),
          child: Stack(
            children: [
              // AMBIENCE: Slow drifting deep-sea bubbles
              ...List.generate(5, (i) => _AmbientDriftBubble(index: i, theme: theme)),

              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCurrentTaskBadge(zen.focusTask, theme),
                      const SizedBox(height: 60),
                      _buildOxygenTimer(context, zen, timeStr, theme),
                      const SizedBox(height: 80),
                      _buildActionFooter(ref, zen, theme),
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

  BoxDecoration _sanctuaryBackground(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
          ? [const Color(0xFF001025), Colors.black]
          : [const Color(0xFFF0F0F0), const Color(0xFFE0E0E0)],
      ),
    );
  }

  Widget _buildCurrentTaskBadge(String? task, ThemeData theme) {
    if (task == null) return const SizedBox.shrink();
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      borderRadius: 20,
      depth: 4,
      child: Text(
        "CURRENT MANEUVER: ${task.toUpperCase()}",
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 2
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2);
  }

  Widget _buildOxygenTimer(BuildContext context, ZenState zen, String timeStr, ThemeData theme) {
    // Progression logic
    final totalSeconds = (zen.remainingSeconds + (zen.isBreathingBreak ? 0 : 0)); // Note: total duration not in state, using approximation
    // Let's assume a standard 25m or whatever was selected.
    // Since we don't have total duration in ZenState, I'll use a local calculation if possible or just a smooth pulse.
    // Better yet, I'll add a smooth indeterminate-like progression or static ring if total is unknown.

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. NEUMORPHIC OUTER RING (The Track)
        Container(
          width: 270,
          height: 270,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                offset: const Offset(10, 10),
                blurRadius: 20,
              ),
              BoxShadow(
                color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.white,
                offset: const Offset(-10, -10),
                blurRadius: 20,
              ),
            ],
          ),
        ),

        // 2. PROGRESSION RING (The Fill)
        SizedBox(
          width: 240,
          height: 240,
          child: CircularProgressIndicator(
            value: null, // Indeterminate for now as totalSeconds is not in state, or I can use (zen.remainingSeconds / (some_initial_value))
            strokeWidth: 8,
            strokeCap: StrokeCap.round,
            color: theme.colorScheme.primary.withOpacity(0.5),
            backgroundColor: Colors.transparent,
          ),
        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),

        // 3. INNER CORE BUBBLE
        NeumorphicContainer(
          shape: BoxShape.circle,
          depth: 6,
          isPressed: true, // Debossed look for the inner core
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.scaffoldBackgroundColor,
            ),
          ),
        ),

        // 4. TIME METRICS
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w200,
                color: theme.colorScheme.onSurface,
                letterSpacing: 2
              ),
            ),
            const SizedBox(height: 4),
            Text(
              zen.isBreathingBreak ? "RECOVERY" : "DEEP SEA",
              style: TextStyle(
                color: theme.colorScheme.primary.withOpacity(0.5),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 4
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionFooter(WidgetRef ref, ZenState zen, ThemeData theme) {
    if (zen.remainingSeconds <= 0) {
      return _SurfaceExitButton(
        onPressed: () => ref.read(zenProvider.notifier).stopSanctuary(),
        theme: theme,
      ).animate().scale().shimmer();
    }

    return Column(
      children: [
        Text(
          "IRON-CLAD LOCK ENGAGED",
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.24),
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 3
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds, color: theme.colorScheme.primary.withOpacity(0.2)),
        const SizedBox(height: 8),
        Text(
          "THE SEA IS CALM. STAY FOCUSED.",
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.1), fontSize: 9),
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
  final ThemeData theme;
  const _AmbientDriftBubble({required this.index, required this.theme});

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
          color: theme.colorScheme.onSurface.withOpacity(0.02),
          border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.03)),
        ),
      ).animate(onPlay: (c) => c.repeat())
       .moveY(begin: 0, end: -1200, duration: (rand.nextInt(15) + 15).seconds)
       .fadeOut(),
    );
  }
}

class _SurfaceExitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ThemeData theme;
  const _SurfaceExitButton({required this.onPressed, required this.theme});

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: 32,
      depth: 10,
      baseColor: theme.colorScheme.primary,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
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
