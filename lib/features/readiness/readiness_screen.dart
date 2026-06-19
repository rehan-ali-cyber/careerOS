import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/database_provider.dart';
import '../../core/persistence/app_database.dart';
import '../../core/theme/glass_theme.dart';

import '../../core/providers/drawer_provider.dart';

class ReadinessScreen extends ConsumerWidget {
  const ReadinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readinessStream = ref.watch(databaseProvider).watchReadiness();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Menu icon removed - Sidebar exclusive to Chat
        title: const Text('Readiness Radar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: GlassTheme.waterGradient),
        child: StreamBuilder<List<ReadinessScore>>(
          stream: readinessStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
            final scores = snapshot.data!;

            if (scores.isEmpty) {
              return const Center(
                child: Text(
                  "Start working on your roadmap\nto build readiness!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 120),
                // Radar Chart with Glass Container
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 320,
                        width: 320,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                        ),
                        child: CustomPaint(
                          painter: RadarPainter(scores),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: scores.length,
                    itemBuilder: (context, index) {
                      final s = scores[index];
                      return _GlassReadinessTile(score: s);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GlassReadinessTile extends StatelessWidget {
  final ReadinessScore score;
  const _GlassReadinessTile({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(score.skillName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${score.score}%', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score.score / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              color: Colors.cyanAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final List<ReadinessScore> scores;
  RadarPainter(this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw circles
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), paint);
    }

    if (scores.isEmpty) return;

    final angleStep = (2 * pi) / scores.length;
    final radarPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    for (var i = 0; i < scores.length; i++) {
      final score = scores[i].score / 100;
      final angle = i * angleStep - pi / 2;
      final x = center.dx + radius * score * cos(angle);
      final y = center.dy + radius * score * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw labels
      final labelX = center.dx + (radius + 20) * cos(angle);
      final labelY = center.dy + (radius + 20) * sin(angle);
      _drawText(canvas, scores[i].skillName, Offset(labelX, labelY), size);
    }
    path.close();

    canvas.drawPath(path, radarPaint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(offset.dx - tp.width / 2, offset.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
