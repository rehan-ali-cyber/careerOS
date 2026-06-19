import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// 1. CHAT HISTORY
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  BoolColumn get isAi => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 2. USER CALIBRATION (The Profile Intelligence)
class UserCalibration extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetCareer => text()();
  IntColumn get skillLevel => integer().withDefault(const Constant(0))(); // 0-10
  IntColumn get dailyHours => integer().withDefault(const Constant(2))();
  TextColumn get dreamCompany => text().nullable()();
  IntColumn get counselingQuestionIndex => integer().withDefault(const Constant(0))();
  TextColumn get counselingContextJson => text().nullable()(); // Stores deep context
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 3. ADAPTIVE ROADMAPS
class RoadmapPaths extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RoadmapSteps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pathId => integer().references(RoadmapPaths, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get aiDeadline => dateTime().nullable()(); // AI calculated deadline
  IntColumn get orderIndex => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

// 4. OPPORTUNITY SCOUT (Background Fragments)
class OpportunityLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get company => text()();
  TextColumn get type => text()(); // Internship, GSoC, Job, etc.
  TextColumn get url => text()();
  IntColumn get minReadinessLevel => integer().withDefault(const Constant(5))();
  DateTimeColumn get foundAt => dateTime().withDefault(currentDateAndTime)();
}

// 5. READINESS SCORES (The Radar)
class ReadinessScores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get skillName => text()();
  IntColumn get score => integer().withDefault(const Constant(0))(); // 0-100
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
}

// 6. HOME SCREEN TARGETS (Long-term Bullets)
class CareerGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deadline => dateTime().nullable()();
}

// 8. DATE-SPECIFIC TASKS (The Planner)
class DailyTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()(); // Links to a specific day
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

// 9. SCHOLAR STREAM LOGS (Video Tracking)
class VideoLearningLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get videoTitle => text()();
  IntColumn get totalDurationSeconds => integer()();
  IntColumn get watchedSeconds => integer()();
  IntColumn get skipCount => integer().withDefault(const Constant(0))();
  RealColumn get sincerityScore => real().withDefault(const Constant(100.0))(); // 0-100
  DateTimeColumn get watchedAt => dateTime().withDefault(currentDateAndTime)();
}

// 10. DIGITAL WELLBEING (Usage Tracking)
class AppUsageLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  TextColumn get appName => text()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get date => dateTime()();
}

// 7. DAILY ATTENDANCE (Smart Calendar)
class DailyAttendance extends Table {
  DateTimeColumn get date => dateTime()(); // Primary Key
  TextColumn get status => text()(); // 'pending', 'completed_on_time', 'completed_late', 'missed'
  BoolColumn get wasManual => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {date};
}

@DriftDatabase(tables: [
  ChatMessages,
  UserCalibration,
  RoadmapPaths,
  RoadmapSteps,
  OpportunityLog,
  ReadinessScores,
  CareerGoals,
  DailyAttendance,
  DailyTasks,
  VideoLearningLogs,
  AppUsageLogs
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 10; // Bump version to 10 for removing usageLimits table

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 7) {
        await m.createTable(dailyTasks);
      }
      if (from < 8) {
        await m.createTable(videoLearningLogs);
      }
      if (from < 9) {
        await m.createTable(appUsageLogs);
      }
      // Force create tables if they don't exist
      await m.createTable(dailyAttendance);

      if (from < 4) {
        try { await m.createTable(userCalibration); } catch (_) {}
        try { await m.createTable(opportunityLog); } catch (_) {}
        try { await m.createTable(readinessScores); } catch (_) {}
        try {
          await m.addColumn(roadmapSteps, roadmapSteps.aiDeadline);
          await m.addColumn(careerGoals, careerGoals.deadline);
        } catch (_) {}
      }
    },
    beforeOpen: (details) async {
      // RULE: Enable foreign keys and verify schema
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // --- REFINED HELPERS ---

  // Chat
  Stream<List<ChatMessage>> watchMessages() => select(chatMessages).watch();
  Future<int> addMessage(ChatMessagesCompanion m) => into(chatMessages).insert(m);
  Future<void> clearChatHistory() => delete(chatMessages).go();

  // Reset All Data (Sovereign Purge)
  Future<void> resetCareerCounseling() async {
    // Order matters because of Foreign Key constraints (e.g., RoadmapSteps references RoadmapPaths)
    await delete(roadmapSteps).go();
    await delete(roadmapPaths).go();
    await delete(chatMessages).go();
    await delete(userCalibration).go();
    await delete(readinessScores).go();
    await delete(opportunityLog).go();
    await delete(dailyAttendance).go();
    await delete(careerGoals).go();
    await delete(dailyTasks).go();
    await delete(videoLearningLogs).go();
    await delete(appUsageLogs).go();
  }

  // Calibration
  Future<int> setCalibration(UserCalibrationData c) => into(userCalibration).insertOnConflictUpdate(c);
  Stream<UserCalibrationData?> watchCalibration() => select(userCalibration).watchSingleOrNull();

  // Readiness
  Stream<List<ReadinessScore>> watchReadiness() => select(readinessScores).watch();
  Future updateReadiness(ReadinessScore s) => update(readinessScores).replace(s);

  // Opportunities
  Stream<List<OpportunityLogData>> watchOpportunities() => select(opportunityLog).watch();

  // Roadmap
  Stream<List<RoadmapPath>> watchRoadmapPaths() => select(roadmapPaths).watch();
  Future<int> addRoadmapPath(RoadmapPathsCompanion p) => into(roadmapPaths).insert(p);
  Future<void> deleteRoadmapPath(int pathId) async {
    await (delete(roadmapSteps)..where((t) => t.pathId.equals(pathId))).go();
    await (delete(roadmapPaths)..where((t) => t.id.equals(pathId))).go();
  }
  Stream<List<RoadmapStep>> watchStepsForPath(int pathId) =>
    (select(roadmapSteps)..where((t) => t.pathId.equals(pathId))
    ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)])).watch();

  // Goals (HomeScreen)
  Stream<List<CareerGoal>> watchGoals() => select(careerGoals).watch();
  Future<int> addGoal(CareerGoalsCompanion goal) => into(careerGoals).insert(goal);

  // New: Watch all steps for home screen
  Stream<List<RoadmapStep>> watchAllSteps() => select(roadmapSteps).watch();

  // Attendance Helpers
  Stream<List<DailyAttendanceData>> watchAttendance() =>
    (select(dailyAttendance)..orderBy([(t) => OrderingTerm(expression: t.date)])).watch();

  Future<int> markAttendance(DailyAttendanceCompanion a) => into(dailyAttendance).insertOnConflictUpdate(a);

  Future<DailyAttendanceData?> getAttendanceForDate(DateTime date) {
    final dayOnly = DateTime(date.year, date.month, date.day);
    return (select(dailyAttendance)..where((t) => t.date.equals(dayOnly))).getSingleOrNull();
  }

  // Daily Tasks Helpers
  Stream<List<DailyTask>> watchTasksForDate(DateTime date) {
    final dayOnly = DateTime(date.year, date.month, date.day);
    return (select(dailyTasks)..where((t) => t.date.equals(dayOnly))).watch();
  }

  Future<int> addDailyTask(DailyTasksCompanion task) => into(dailyTasks).insert(task);

  Future updateDailyTask(DailyTask task) => update(dailyTasks).replace(task);

  Future deleteDailyTask(DailyTask task) => delete(dailyTasks).delete(task);

  // Video Learning Logs Helpers
  Stream<List<VideoLearningLog>> watchVideoLogs() => select(videoLearningLogs).watch();
  Future<int> addVideoLog(VideoLearningLogsCompanion log) => into(videoLearningLogs).insert(log);

  // Digital Wellbeing Helpers
  Stream<List<AppUsageLog>> watchUsageForDate(DateTime date) {
    final dayOnly = DateTime(date.year, date.month, date.day);
    return (select(appUsageLogs)..where((t) => t.date.equals(dayOnly))).watch();
  }

  Future<void> updateUsage(String packageName, String appName, int secondsToAdd) async {
    final today = DateTime.now();
    final dayOnly = DateTime(today.year, today.month, today.day);

    final existing = await (select(appUsageLogs)
          ..where((t) => t.packageName.equals(packageName) & t.date.equals(dayOnly)))
        .getSingleOrNull();

    if (existing == null) {
      await into(appUsageLogs).insert(AppUsageLogsCompanion.insert(
        packageName: packageName,
        appName: appName,
        durationSeconds: Value(secondsToAdd),
        date: dayOnly,
      ));
    } else {
      await (update(appUsageLogs)..where((t) => t.id.equals(existing.id))).write(
        AppUsageLogsCompanion(
          durationSeconds: Value(existing.durationSeconds + secondsToAdd),
        ),
      );
    }
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'career_os_db',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
