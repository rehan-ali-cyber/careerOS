import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/progress_card.dart';
import '../../core/providers/database_provider.dart';
import '../../core/persistence/preferences_service.dart';
import '../../core/persistence/app_database.dart';
import '../../core/widgets/beautiful_background.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/providers/drawer_provider.dart';
import '../../core/providers/stats_provider.dart';
import '../calendar/widgets/day_task_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(attendanceServiceProvider).syncMissedDays());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildSidebarTrigger(),
        actions: [_buildThemeToggle(), const SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildDailyBriefingHub(),
              const SizedBox(height: 28),

              _buildSectionLabel("MISSION CONSISTENCY"),
              const _AttendanceTracker(),
              const SizedBox(height: 28),

              _buildSectionLabel("COMMAND METRICS"),
              const _LiveReadinessCard(),
              const SizedBox(height: 24),

              _buildSectionLabel("IMMEDIATE MANEUVERS"),
              const _CurrentManeuversList(),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarTrigger() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: NeumorphicContainer(
        shape: BoxShape.circle,
        depth: 4,
        child: IconButton(
          icon: Icon(Icons.menu_rounded, color: Theme.of(context).colorScheme.onSurface, size: 24),
          onPressed: () => ref.read(scaffoldKeyProvider).currentState?.openDrawer(),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final settings = ref.watch(settingsProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: NeumorphicContainer(
        shape: BoxShape.circle,
        depth: 4,
        child: IconButton(
          icon: Icon(
            settings.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          onPressed: () => ref.read(settingsProvider.notifier).toggleTheme(),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2
        ),
      ).animate().fadeIn(duration: 600.ms),
    );
  }
}

class _LiveReadinessCard extends ConsumerWidget {
  const _LiveReadinessCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readiness = ref.watch(statsProvider.select((s) => s.careerReadiness));

    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 30,
      depth: 10,
      child: ProgressCard(
        title: "Overall Career Readiness",
        progress: readiness,
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _CurrentManeuversList extends ConsumerWidget {
  const _CurrentManeuversList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepsStream = ref.watch(databaseProvider).watchAllSteps();

    return StreamBuilder<List<RoadmapStep>>(
      stream: stepsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const _EmptyStateCard();
        }

        final pending = snapshot.data!.where((s) => !s.isCompleted).take(3).toList();
        if (pending.isEmpty) return const _EmptyStateCard();

        return NeumorphicContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 30,
          depth: 10,
          child: Column(
            children: pending.map((step) => _WateryTaskTile(title: step.title)).toList(),
          ),
        );
      },
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05);
  }
}

  Widget _buildDailyBriefingHub() {
    final userName = PreferencesService.getUserName();
    final calibration = ref.watch(databaseProvider).watchCalibration();

    return StreamBuilder<UserCalibrationData?>(
      stream: calibration,
      builder: (context, snapshot) {
        final career = snapshot.data?.targetCareer ?? "Voyager";
        final qIndex = snapshot.data?.counselingQuestionIndex ?? 0;

        String briefing = "Your roadmap for $career is optimized.";
        if (qIndex > 0 && qIndex < 31) briefing = "Currently calibrating professional DNA (Q$qIndex/30).";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Greetings, $userName",
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -1.5),
            ).animate().fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 4),
            Text(
              briefing.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5),
            ).animate().fadeIn(delay: 200.ms),
          ],
        );
      },
    );
  }
}

class _AttendanceTracker extends ConsumerStatefulWidget {
  const _AttendanceTracker();
  @override
  ConsumerState<_AttendanceTracker> createState() => _AttendanceTrackerState();
}

class _AttendanceTrackerState extends ConsumerState<_AttendanceTracker> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 20 * 62.0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(attendanceStreamProvider);

    return SizedBox(
      height: 90,
      child: attendanceAsync.when(
        data: (data) {
          final now = DateTime.now();
          final days = List.generate(30, (i) =>
            DateTime(now.year, now.month, now.day).subtract(Duration(days: 20 - i))
          );

          return ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isToday = index == 20;

              final status = data.firstWhere((a) =>
                a.date.year == date.year && a.date.month == date.month && a.date.day == date.day,
                orElse: () => DailyAttendanceData(date: date, status: 'pending', wasManual: false)
              ).status;

              return _AttendanceBubble(date: date, status: status, isToday: isToday);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white12)),
        error: (_, __) => const SizedBox(),
      ),
    );
  }
}

class _AttendanceBubble extends ConsumerWidget {
  final DateTime date;
  final String status;
  final bool isToday;

  const _AttendanceBubble({required this.date, required this.status, required this.isToday});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color color = isToday ? Colors.cyanAccent : Colors.white10;
    if (status == 'completed_on_time') color = Colors.greenAccent;
    if (status == 'completed_late') color = Colors.amberAccent;
    if (status == 'missed') color = Colors.redAccent.withOpacity(0.5);

    final isPressed = status != 'pending';

    return GestureDetector(
      onTap: () => ref.read(attendanceServiceProvider).toggleAttendance(date),
      onLongPress: () => _showDayTaskDialog(context, date),
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: NeumorphicContainer(
          borderRadius: 18,
          depth: isToday ? 4 : 2,
          isPressed: isPressed,
          baseColor: isToday ? const Color(0xFF202020) : const Color(0xFF1A1A1A),
          child: Container(
            width: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date).substring(0, 1),
                  style: TextStyle(color: isToday ? Colors.white : Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 2),
                Text(
                  date.day.toString(),
                  style: TextStyle(color: isToday ? Colors.cyanAccent : Colors.white, fontWeight: FontWeight.w900, fontSize: 16)
                ),
                if (isPressed && status != 'missed')
                  Icon(Icons.check_rounded, size: 10, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDayTaskDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => DayTaskDialog(date: date),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();
  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(40),
      borderRadius: 30,
      depth: 6,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.anchor_rounded, color: Colors.white.withOpacity(0.1), size: 40),
            const SizedBox(height: 12),
            const Text("NO ACTIVE MANEUVERS", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}

class _WateryTaskTile extends StatelessWidget {
  final String title;
  const _WateryTaskTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicContainer(
        borderRadius: 18,
        depth: 4,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            NeumorphicContainer(
              shape: BoxShape.circle,
              depth: 2,
              baseColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(4),
              child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)
              )
            ),
          ],
        ),
      ),
    );
  }
}
