import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/persistence/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/beautiful_background.dart';
import '../../core/providers/attendance_provider.dart';
import '../chat/providers/career_pilot_provider.dart';

/**
 * RoadmapTrackScreen: An interactive, scrollable voyage journey.
 * Visualizes career steps as a physical winding road with hurdles.
 */
class RoadmapTrackScreen extends ConsumerWidget {
  final RoadmapPath path;
  const RoadmapTrackScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildBackButton(context),
        title: Text(path.title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w200, color: Colors.white, fontSize: 16, letterSpacing: 3)),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: BeautifulBackground()),
          _MovableVoyageTrack(path: path),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white24, size: 20),
      onPressed: () => Navigator.pop(context),
    );
  }
}

class _MovableVoyageTrack extends ConsumerStatefulWidget {
  final RoadmapPath path;
  const _MovableVoyageTrack({required this.path});

  @override
  ConsumerState<_MovableVoyageTrack> createState() => _MovableVoyageTrackState();
}

class _MovableVoyageTrackState extends ConsumerState<_MovableVoyageTrack> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final stepsStream = db.watchStepsForPath(widget.path.id);

    return StreamBuilder<List<RoadmapStep>>(
      stream: stepsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white12));

        final steps = snapshot.data!;
        final completedCount = steps.where((s) => s.isCompleted).length;

        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.only(top: 180, bottom: 250),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. THE CINEMATIC ROAD
                    Positioned.fill(
                      child: CustomPaint(
                        painter: VoyageRoadPainter(
                          stepsCount: steps.length,
                          completedCount: completedCount,
                        ),
                      ),
                    ),

                    // 2. THE HURDLES (Milestones)
                    Column(
                      children: List.generate(steps.length, (index) {
                        final step = steps[index];
                        final bool isLeft = index % 2 == 0;
                        return _VoyageHurdle(
                          step: step,
                          isLeft: isLeft,
                          index: index,
                        );
                      }),
                    ),

                    _buildTerminalNode(steps.length),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTerminalNode(int count) {
    return Positioned(
      top: -60,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
          ),
          child: const Text("VOYAGE ORIGIN", style: TextStyle(color: Colors.white12, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
      ),
    );
  }
}

class _VoyageHurdle extends ConsumerWidget {
  final RoadmapStep step;
  final bool isLeft;
  final int index;

  const _VoyageHurdle({required this.step, required this.isLeft, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 260, // Fixed segment length
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // THE HULL HUB (Interaction Point)
          Positioned(
            top: 0,
            left: isLeft ? 65 : null,
            right: !isLeft ? 65 : null,
            child: _HurdleActionNode(step: step, index: index),
          ),

          // THE MANEUVER CARD (Information)
          Positioned(
            top: 110,
            left: isLeft ? 40 : null,
            right: !isLeft ? 40 : null,
            width: 230,
            child: _ManeuverCard(step: step).animate().fadeIn(delay: (index * 50 + 200).ms).slideY(begin: 0.1),
          ),
        ],
      ),
    );
  }
}

class _HurdleActionNode extends ConsumerWidget {
  final RoadmapStep step;
  final int index;
  const _HurdleActionNode({required this.step, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool done = step.isCompleted;

    return GestureDetector(
      onTap: () async {
        final db = ref.read(databaseProvider);
        final attendance = ref.read(attendanceServiceProvider);

        final updatedStep = step.copyWith(isCompleted: !done);
        await db.update(db.roadmapSteps).replace(updatedStep);

        if (updatedStep.isCompleted) {
          await attendance.markProgress(DateTime.now());
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: done
                ? const LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent], begin: Alignment.topLeft)
                : LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]),
              border: Border.all(color: done ? Colors.white : Colors.white10, width: 3),
              boxShadow: [
                if (done) BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 25, spreadRadius: 2),
              ],
            ),
            child: Center(
              child: Icon(
                done ? Icons.verified_rounded : Icons.radar_rounded,
                color: done ? Colors.black : Colors.white24,
                size: 32,
              ),
            ),
          ).animate().scale(delay: (index * 40).ms),
          const SizedBox(height: 10),
          Text(
            "LEG 0${index + 1}",
            style: TextStyle(color: done ? Colors.cyanAccent : Colors.white.withOpacity(0.05), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2)
          ),
        ],
      ),
    );
  }
}

class _ManeuverCard extends StatelessWidget {
  final RoadmapStep step;
  const _ManeuverCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
              ),
              if (step.description != null) ...[
                const SizedBox(height: 6),
                Text(
                  step.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class VoyageRoadPainter extends CustomPainter {
  final int stepsCount;
  final int completedCount;
  VoyageRoadPainter({required this.stepsCount, required this.completedCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (stepsCount == 0) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 70
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 70
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double segHeight = 260.0;

    path.moveTo(size.width / 2, 0);

    for (int i = 0; i < stepsCount; i++) {
      final double y = (i * segHeight);
      final double nextY = ((i + 1) * segHeight);
      final double cpX = (i % 2 == 0) ? 50 : size.width - 50;
      path.quadraticBezierTo(cpX, y + segHeight / 2, size.width / 2, nextY);
    }

    canvas.drawPath(path, paint);

    if (completedCount > 0) {
      final donePath = Path();
      donePath.moveTo(size.width / 2, 0);
      for (int i = 0; i < completedCount; i++) {
        final double y = (i * segHeight);
        final double nextY = ((i + 1) * segHeight);
        final double cpX = (i % 2 == 0) ? 50 : size.width - 50;
        donePath.quadraticBezierTo(cpX, y + segHeight / 2, size.width / 2, nextY);
      }
      canvas.drawPath(donePath, progressPaint);
    }

    // High-End Dashed Center Line
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _drawDashedVoyagePath(canvas, path, dashPaint);
  }

  void _drawDashedVoyagePath(Canvas canvas, Path path, Paint paint) {
    for (PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 20), paint);
        distance += 40;
      }
    }
  }

  @override
  bool shouldRepaint(covariant VoyageRoadPainter old) =>
    old.stepsCount != stepsCount || old.completedCount != completedCount;
}
