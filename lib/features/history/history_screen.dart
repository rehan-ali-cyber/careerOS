import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/persistence/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';
import '../../core/providers/drawer_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeumorphicContainer(
            shape: BoxShape.circle,
            depth: 4,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: theme.colorScheme.onSurface, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text('Career Milestones',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      ),
      body: StreamBuilder<List<RoadmapStep>>(
        stream: db.watchAllSteps(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final completedSteps = snapshot.data!.where((s) => s.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 40),
            physics: const BouncingScrollPhysics(),
            children: [
              const _HistoryHeader(),
              const SizedBox(height: 32),

              if (completedSteps.isEmpty)
                const _EmptyHistory()
              else
                ...completedSteps.map((step) => _MilestoneTile(step: step)),

              const SizedBox(height: 32),

              // --- NEW: DEEP STUDY LOGS ---
              const _StudyLedgerSection(),

              const SizedBox(height: 32),
              const _CounselingLogSection(),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Achievement Log",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          "Every step taken is a victory recorded.",
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final RoadmapStep step;
  const _MilestoneTile({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeumorphicContainer(
        borderRadius: 24,
        depth: 6,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              NeumorphicContainer(
                padding: const EdgeInsets.all(12),
                shape: BoxShape.circle,
                depth: 2,
                baseColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.verified_rounded, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Completed on Discovery Journey",
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounselingLogSection extends StatelessWidget {
  const _CounselingLogSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 24,
      depth: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Counseling Sessions", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _LogItem(title: "Initial Calibration", date: "Today", icon: Icons.psychology),
            const SizedBox(height: 12),
            _LogItem(title: "Roadmap Generation", date: "Today", icon: Icons.auto_awesome),
          ],
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;

  const _LogItem({required this.title, required this.date, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.38), size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)))),
        Text(date, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.24), fontSize: 12)),
      ],
    );
  }
}

class _StudyLedgerSection extends ConsumerWidget {
  const _StudyLedgerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsStream = ref.watch(databaseProvider).watchVideoLogs();
    final theme = Theme.of(context);

    return StreamBuilder<List<VideoLearningLog>>(
      stream: logsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        final logs = snapshot.data!.reversed.toList(); // Most recent first

        return NeumorphicContainer(
          borderRadius: 24,
          depth: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Deep Study Logs", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.bold)),
                    Icon(Icons.auto_stories_rounded, color: theme.colorScheme.primary.withOpacity(0.3), size: 18),
                  ],
                ),
                const SizedBox(height: 16),
                ...logs.take(5).map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StudyLogItem(log: log),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudyLogItem extends StatelessWidget {
  final VideoLearningLog log;
  const _StudyLogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = log.sincerityScore.toInt();
    final isGood = score >= 80;

    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: isGood ? Colors.greenAccent : Colors.orangeAccent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            log.videoTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "$score%",
          style: TextStyle(
            color: isGood ? Colors.greenAccent.withOpacity(0.5) : Colors.orangeAccent.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.history_toggle_off_rounded, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text("No milestones achieved yet.", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3))),
          Text("Finish tasks in your Roadmap to see them here!", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.24), fontSize: 12)),
        ],
      ),
    );
  }
}
