import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/lockdown_service.dart';
import '../../../core/providers/settings_provider.dart';

/**
 * ZenState represents the immutable condition of the Zen Sanctuary session.
 */
class ZenState {
  final bool isActive;
  final int remainingSeconds;
  final String? focusTask;
  final bool isLocked;
  final bool isBreathingBreak;

  ZenState({
    this.isActive = false,
    this.remainingSeconds = 0,
    this.focusTask,
    this.isLocked = false,
    this.isBreathingBreak = false,
  });

  ZenState copyWith({
    bool? isActive,
    int? remainingSeconds,
    String? focusTask,
    bool? isLocked,
    bool? isBreathingBreak,
  }) {
    return ZenState(
      isActive: isActive ?? this.isActive,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      focusTask: focusTask ?? this.focusTask,
      isLocked: isLocked ?? this.isLocked,
      isBreathingBreak: isBreathingBreak ?? this.isBreathingBreak,
    );
  }
}

/**
 * ZenNotifier manages the lifecycle of a Deep Focus session.
 * It coordinates with the native LockdownService to enforce strict system-level locking.
 */
class ZenNotifier extends StateNotifier<ZenState> {
  final Ref ref;
  ZenNotifier(this.ref) : super(ZenState()) {
    _setupMethodChannel();
  }

  static const _channel = MethodChannel('com.example.careeros/lockdown');
  Timer? _ticker;

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onUnpinned') {
        _handleCommitmentBreak();
      }
    });
  }

  void _handleCommitmentBreak() {
    if (state.isActive && state.isLocked) {
      // Log the broken commitment
      ref.read(settingsProvider.notifier).incrementCommitmentBreaks();

      // We don't stop the session, but it's no longer "locked" in the native sense
      state = state.copyWith(isLocked: false);
    }
  }

  // ────────────────────────────────────────────────────────────
  // 1. CORE SESSION CONTROL
  // ────────────────────────────────────────────────────────────

  Future<void> startSanctuary(int minutes, String? task) async {
    state = state.copyWith(
      isActive: true,
      remainingSeconds: minutes * 60,
      focusTask: task,
      isLocked: true,
      isBreathingBreak: false,
    );

    // Initialize strict system-level protocols
    await _activateCommandGuard();

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _processTick();
    });
  }

  Future<void> stopSanctuary() async {
    _ticker?.cancel();

    // Gracefully restore system control
    await _releaseCommandGuard();

    state = state.copyWith(
      isActive: false,
      isLocked: false,
      remainingSeconds: 0,
      isBreathingBreak: false,
    );
  }

  // ────────────────────────────────────────────────────────────
  // 2. INTERNAL TICK LOGIC
  // ────────────────────────────────────────────────────────────

  void _processTick() {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);

      // AGGRESSIVE RE-LOCK: Every second, force system UI into deep-freeze
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      // VOYAGE RECOVERY: Trigger a 2-minute breathing break every 45 minutes
      if (state.remainingSeconds % 2700 == 0 && state.remainingSeconds > 0) {
         _initiateBreathingBreak();
      }
    } else {
      stopSanctuary();
    }
  }

  // ────────────────────────────────────────────────────────────
  // 3. SYSTEM INTERFACE HELPERS
  // ────────────────────────────────────────────────────────────

  Future<void> _activateCommandGuard() async {
    // 1. Enter Immersive Mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // 2. Kill Spotify / Music
    await LockdownService.hijackAudio();
    // 3. Freeze Hardware Buttons
    await LockdownService.startLockdown();
  }

  Future<void> _releaseCommandGuard() async {
    // 1. Restore System UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    // 2. Release Audio Focus
    await LockdownService.releaseAudio();
    // 3. Unfreeze Buttons
    await LockdownService.stopLockdown();
  }

  void _initiateBreathingBreak() {
    state = state.copyWith(isBreathingBreak: true);

    // Auto-resume focus mode after 2 minutes of recovery
    Future.delayed(const Duration(minutes: 2), () {
      if (mounted && state.isActive) {
        state = state.copyWith(isBreathingBreak: false);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _releaseCommandGuard();
    super.dispose();
  }
}

// THE GLOBAL ZEN CONTROLLER
final zenProvider = StateNotifierProvider<ZenNotifier, ZenState>((ref) => ZenNotifier(ref));
