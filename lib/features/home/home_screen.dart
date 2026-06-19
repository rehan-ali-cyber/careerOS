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
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/beautiful_background.dart';
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildSidebarTrigger(),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: BeautifulBackground()),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const _DailyBriefingHub(),
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
        ],
      ),
    );
  }

  Widget _buildSidebarTrigger() {
    return IconButton(
      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
      onPressed: () => ref.read(scaffoldKeyProvider).currentState?.openDrawer(),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.2),
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

    return _GlassBento(
      padding: const EdgeInsets.all(24),
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

        return _GlassBento(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: pending.map((step) => _WateryTaskTile(title: step.title)).toList(),
          ),
        );
      },
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05);
  }
}

class _DailyBriefingHub extends ConsumerWidget {
  const _DailyBriefingHub();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.5),
            ).animate().fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 4),
            Text(
              briefing.toUpperCase(),
              style: const TextStyle(fontSize: 10, color: Colors.cyanAccent, fontWeight: FontWeight.w800, letterSpacing: 1.5),
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

    return Container(
      height: 75,
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

    return GestureDetector(
      onTap: () => ref.read(attendanceServiceProvider).toggleAttendance(date),
      onLongPress: () => _showDayTaskDialog(context, date),
      child: Container(
        width: 52,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(isToday ? 0.15 : 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withOpacity(isToday ? 0.6 : 0.2),
            width: isToday ? 1.5 : 0.8,
          ),
        ),
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)
            ),
            if (status != 'pending' && status != 'missed')
              Icon(Icons.check_rounded, size: 10, color: color.withOpacity(0.8)),
          ],
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
    return _GlassBento(
      padding: const EdgeInsets.all(40),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)
            )
          ),
        ],
      ),
    );
  }
}

class _GlassBento extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _GlassBento({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
