import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../persistence/app_database.dart';
import 'package:drift/drift.dart' as drift;

class AttendanceService {
  final AppDatabase _db;

  AttendanceService(this._db);

  /// Fetch correct date from internet to prevent cheating
  Future<DateTime> getInternetDate() async {
    try {
      final response = await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/Etc/UTC')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DateTime.parse(data['datetime']).toLocal();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('NTP Check Failed: $e. Falling back to local time.');
    }
    return DateTime.now();
  }

  /// Toggle attendance for a specific date
  Future<void> toggleAttendance(DateTime date) async {
    final now = await getInternetDate();
    final targetDay = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    // RULE 1: DISALLOW FUTURE TICKING
    if (targetDay.isAfter(today)) {
      if (kDebugMode) debugPrint("Attendance: Cannot mark future dates.");
      return;
    }

    final existing = await _db.getAttendanceForDate(targetDay);

    if (existing != null && (existing.status == 'completed_on_time' || existing.status == 'completed_late')) {
      // Untick: Reset to pending or missed
      final newStatus = targetDay.isBefore(today) ? 'missed' : 'pending';
      await _db.markAttendance(DailyAttendanceCompanion.insert(
        date: targetDay,
        status: newStatus,
        wasManual: const drift.Value(true),
      ));
    } else {
      // Tick: Determine Color
      // GREEN (on_time): ONLY if targetDay is exactly TODAY
      // YELLOW (late): If targetDay is in the PAST
      String status = (targetDay.isAtSameMomentAs(today)) ? 'completed_on_time' : 'completed_late';

      await _db.markAttendance(DailyAttendanceCompanion.insert(
        date: targetDay,
        status: status,
        wasManual: const drift.Value(true),
      ));
    }
  }

  /// Mark today's progress as Green (on time) or Yellow (late)
  Future<void> markTodayAsCompleted({bool manual = true}) async {
    final now = await getInternetDate();
    final dayOnly = DateTime(now.year, now.month, now.day);

    // Check if we already have an entry for today
    final existing = await _db.getAttendanceForDate(dayOnly);

    if (existing != null && (existing.status == 'completed_on_time' || existing.status == 'completed_late')) {
      return; // Already marked
    }

    // Logic: If it's today, it's Green. If it's a past day, it's Yellow.
    // Since this method is usually called "today", we default to Green.
    // However, if we were to allow marking past days, we'd check against 'now'.

    await _db.markAttendance(DailyAttendanceCompanion.insert(
      date: dayOnly,
      status: 'completed_on_time',
      wasManual: drift.Value(manual),
    ));
  }

  /// Mark a specific date (milestone click)
  Future<void> markProgress(DateTime taskDate) async {
    final now = await getInternetDate();
    final taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);
    final today = DateTime(now.year, now.month, now.day);

    String status = 'completed_on_time';
    if (taskDay.isBefore(today)) {
      status = 'completed_late';
    }

    await _db.markAttendance(DailyAttendanceCompanion.insert(
      date: taskDay,
      status: status,
      wasManual: const drift.Value(false),
    ));
  }

  /// Auto-fill missing days as Red (only for past days)
  Future<void> syncMissedDays() async {
    final now = await getInternetDate();
    final today = DateTime(now.year, now.month, now.day);

    // Fill last 20 days (as requested)
    for (int i = 1; i <= 20; i++) {
      final date = today.subtract(Duration(days: i));
      final existing = await _db.getAttendanceForDate(date);

      if (existing == null) {
        await _db.markAttendance(DailyAttendanceCompanion.insert(
          date: date,
          status: 'missed',
          wasManual: const drift.Value(false),
        ));
      }
    }
  }
}
