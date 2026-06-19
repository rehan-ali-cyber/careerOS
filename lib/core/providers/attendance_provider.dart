import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/app_database.dart';
import '../services/attendance_service.dart';
import 'database_provider.dart';

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  final db = ref.watch(databaseProvider);
  return AttendanceService(db);
});

final attendanceStreamProvider = StreamProvider<List<DailyAttendanceData>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAttendance();
});
