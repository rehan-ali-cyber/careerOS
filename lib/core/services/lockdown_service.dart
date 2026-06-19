import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/**
 * LockdownService act as the bridge between Flutter and the Sovereign Commander (Native Android).
 * It manages hardware-level locks, audio hijacking, and system permissions.
 */
class LockdownService {

  // NATIVE CHANNEL ID
  static const _channel = MethodChannel('com.example.careeros/lockdown');

  // ────────────────────────────────────────────────────────────
  // 1. HARDWARE COMMANDS
  // ────────────────────────────────────────────────────────────

  /// Freezes physical Home and Recents buttons using Android's Lock Task Mode.
  static Future<void> startLockdown() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _channel.invokeMethod('startLockdown');
      }
    } catch (e) {
      debugPrint("Lockdown Internal Error: $e");
    }
  }

  /// Releases hardware locks and restores normal device navigation.
  static Future<void> stopLockdown() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _channel.invokeMethod('stopLockdown');
      }
    } catch (e) {
      debugPrint("Lockdown Internal Error: $e");
    }
  }

  // ────────────────────────────────────────────────────────────
  // 2. AUDIO MANAGEMENT (The "Spotify Killer")
  // ────────────────────────────────────────────────────────────

  /// Commands the system to seize Audio Focus, forcing Spotify/External players to pause.
  static Future<void> hijackAudio() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _channel.invokeMethod('hijackAudio');
      }
    } catch (e) {
      debugPrint("Audio Sentry Error: $e");
    }
  }

  /// Releases Audio Focus so the user can play music again after the session.
  static Future<void> releaseAudio() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _channel.invokeMethod('releaseAudio');
      }
    } catch (e) {
      debugPrint("Audio Sentry Error: $e");
    }
  }

  // ────────────────────────────────────────────────────────────
  // 3. PERMISSION PROTOCOLS
  // ────────────────────────────────────────────────────────────

  /// Verification: Does the app have authority to kill notifications?
  static Future<bool> hasDndAccess() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    return await Permission.accessNotificationPolicy.isGranted;
  }

  /// Action: Request Do Not Disturb authority from the user.
  static Future<void> requestDndAccess() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.accessNotificationPolicy.request();
    }
  }

  /// Verification: Does the app have authority to block background switching?
  static Future<bool> hasOverlayAccess() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    return await Permission.systemAlertWindow.isGranted;
  }

  /// Action: Request "Draw Over Other Apps" authority.
  static Future<void> requestOverlayAccess() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.systemAlertWindow.request();
    }
  }

  /// Advanced Verification: Has the user authorized "Device Owner" status via ADB?
  static Future<bool> isDeviceOwner() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return await _channel.invokeMethod('isDeviceOwner') ?? false;
    } catch (_) {
      return false;
    }
  }
}
