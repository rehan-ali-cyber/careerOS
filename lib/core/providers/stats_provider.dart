import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/app_database.dart';
import 'database_provider.dart';
import 'attendance_provider.dart';

class UserStats {
  final int currentStreak;
  final double careerReadiness;
  final int totalSteps;
  final int completedSteps;
  final int activeRoadmaps;

  UserStats({
    this.currentStreak = 0,
    this.careerReadiness = 0.0,
    this.totalSteps = 0,
    this.completedSteps = 0,
    this.activeRoadmaps = 0,
  });
}

final stepsStreamProvider = StreamProvider<List<RoadmapStep>>((ref) {
  return ref.watch(databaseProvider).watchAllSteps();
});

final pathsStreamProvider = StreamProvider<List<RoadmapPath>>((ref) {
  return ref.watch(databaseProvider).watchRoadmapPaths();
});

final statsProvider = Provider<UserStats>((ref) {
  final attendance = ref.watch(attendanceStreamProvider).value ?? [];
  final steps = ref.watch(stepsStreamProvider).value ?? [];
  final paths = ref.watch(pathsStreamProvider).value ?? [];

  // Calculate Streak
  int streak = 0;
  final sortedAttendance = List<DailyAttendanceData>.from(attendance)
    ..sort((a, b) => b.date.compareTo(a.date));

  final today = DateTime.now();
  final todayDay = DateTime(today.year, today.month, today.day);

  for (var entry in sortedAttendance) {
    if (entry.status == 'completed_on_time' || entry.status == 'completed_late') {
      streak++;
    } else if (entry.date.isBefore(todayDay)) {
      break;
    }
  }

  // Calculate Readiness
  int completed = steps.where((s) => s.isCompleted).length;
  double readiness = steps.isEmpty ? 0.0 : completed / steps.length;

  return UserStats(
    currentStreak: streak,
    careerReadiness: readiness,
    totalSteps: steps.length,
    completedSteps: completed,
    activeRoadmaps: paths.length,
  );
});
