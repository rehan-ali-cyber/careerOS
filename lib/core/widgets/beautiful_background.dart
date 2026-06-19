import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/glass_theme.dart';

class BeautifulBackground extends StatelessWidget {
  const BeautifulBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Static Gradient Base
        Positioned.fill(
          child: RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(gradient: GlassTheme.waterGradient),
            ),
          ),
        ),

        // 2. Optimized Perspective Grid
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),
        ),

        // 3. Ultra-Smooth Star Field (Optimized Count: 15)
        ...List.generate(15, (index) {
          final random = Random(index);
          final top = random.nextDouble() * 1000;
          final left = random.nextDouble() * 600;
          final size = random.nextDouble() * 1.5 + 1;
          final duration = (random.nextInt(3000) + 3000).ms;

          return Positioned(
            top: top % (MediaQuery.of(context).size.height + 200),
            left: left % (MediaQuery.of(context).size.width + 100),
            child: RepaintBoundary(
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .fadeIn(duration: duration),
            ),
          );
        }),

        // 4. Slow Drifting Orbs (REPAINT BOUNDARY MOVED INSIDE)
        _FloatingOrb(
          color: Colors.cyanAccent.withOpacity(0.1),
          size: 300,
          initialOffset: const Offset(-80, 150),
          driftOffset: const Offset(40, 40),
          duration: 15.seconds,
        ),
        _FloatingOrb(
          color: Colors.purpleAccent.withOpacity(0.08),
          size: 400,
          initialOffset: const Offset(180, 450),
          driftOffset: const Offset(-30, -60),
          duration: 20.seconds,
        ),

        // 5. Cinematic Python Ghost (Ultra Slow)
        const Center(
          child: RepaintBoundary(
            child: _MovingPythonDecoration(),
          ),
        ),
      ],
    );
  }
}

class _MovingPythonDecoration extends StatelessWidget {
  const _MovingPythonDecoration();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.07,
      child: CustomPaint(
        size: const Size(250, 250),
        painter: _PythonLogoPainter(),
      ),
    ).animate(onPlay: (c) => c.repeat())
     .rotate(duration: 60.seconds, begin: 0, end: 1) // Ultra slow rotation
     .move(
       begin: const Offset(-10, -10),
       end: const Offset(10, 10),
       duration: 30.seconds,
       curve: Curves.easeInOutSine
     );
  }
}

class _PythonLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..color = Colors.blue.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final yellowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double r = w * 0.15;

    final topPath = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.2, h * 0.1)
      ..arcToPoint(Offset(w * 0.1, h * 0.2), radius: Radius.circular(r))
      ..lineTo(w * 0.1, h * 0.4)
      ..arcToPoint(Offset(w * 0.2, h * 0.5), radius: Radius.circular(r))
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.5, h * 0.4)
      ..lineTo(w * 0.3, h * 0.4)
      ..arcToPoint(Offset(w * 0.25, h * 0.35), radius: Radius.circular(r/2), clockwise: false)
      ..lineTo(w * 0.25, h * 0.25)
      ..arcToPoint(Offset(w * 0.3, h * 0.2), radius: Radius.circular(r/2), clockwise: false)
      ..lineTo(w * 0.5, h * 0.2)
      ..close();

    canvas.save();
    canvas.drawPath(topPath, bluePaint);
    canvas.translate(w, h);
    canvas.rotate(pi);
    canvas.drawPath(topPath, yellowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingOrb extends StatelessWidget {
  final Color color;
  final double size;
  final Offset initialOffset;
  final Offset driftOffset;
  final Duration duration;

  const _FloatingOrb({
    required this.color,
    required this.size,
    required this.initialOffset,
    required this.driftOffset,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    // FIXED: RepaintBoundary is now a child of Positioned, not a parent.
    return Positioned(
      left: initialOffset.dx,
      top: initialOffset.dy,
      child: RepaintBoundary(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 100,
                spreadRadius: 40,
              ),
            ],
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .move(
           begin: Offset.zero,
           end: driftOffset,
           duration: duration,
           curve: Curves.easeInOutSine,
         ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const double spacing = 80.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
