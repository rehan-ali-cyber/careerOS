import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../core/persistence/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/providers/attendance_provider.dart';
import 'widgets/day_task_dialog.dart';

class LifetimeCalendarScreen extends ConsumerWidget {
  const LifetimeCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceStreamProvider);
    final now = DateTime.now();
    final currentYear = now.year;
    const startYear = 2026;

    // Calculate how many years to show (from 2026 to now)
    final yearCount = currentYear >= startYear ? (currentYear - startYear) + 1 : 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Lifetime Voyage Log', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: GlassTheme.waterGradient),
        child: attendanceAsync.when(
          data: (data) {
            if (yearCount == 0) {
              return const Center(child: Text("Voyage begins in 2026.", style: TextStyle(color: Colors.white70)));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 40),
              physics: const BouncingScrollPhysics(),
              itemCount: yearCount,
              itemBuilder: (context, index) {
                // Show years in descending order (2027, 2026...)
                final year = currentYear - index;
                if (year < startYear) return const SizedBox.shrink();

                return _YearlyVoyage(year: year, attendanceData: data);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (err, _) => Center(child: Text("Error loading log: $err", style: const TextStyle(color: Colors.red))),
        ),
      ),
    );
  }
}

class _YearlyVoyage extends StatelessWidget {
  final int year;
  final List<DailyAttendanceData> attendanceData;

  const _YearlyVoyage({required this.year, required this.attendanceData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Row(
            children: [
              Text(
                year.toString(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
              ),
              const SizedBox(width: 12),
              Container(height: 2, width: 40, color: Colors.cyanAccent.withOpacity(0.3)),
            ],
          ),
        ),
        // Group by Months in REVERSE order (Recent on top)
        ...List.generate(12, (mIndex) {
          final month = 12 - mIndex; // Starts from 12 (Dec) down to 1

          final now = DateTime.now();
          // Don't show future months for current year
          if (year == now.year && month > now.month) return const SizedBox.shrink();

          return _MonthlySegment(
            year: year,
            month: month,
            attendanceData: attendanceData
          );
        }),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _MonthlySegment extends StatelessWidget {
  final int year;
  final int month;
  final List<DailyAttendanceData> attendanceData;

  const _MonthlySegment({required this.year, required this.month, required this.attendanceData});

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM').format(DateTime(year, month));
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 12),
            child: Text(
              monthName.toUpperCase(),
              style: TextStyle(color: Colors.cyanAccent.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
          ),
          _GlassBento(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(daysInMonth, (dIndex) {
                final day = dIndex + 1;
                final date = DateTime(year, month, day);

                final status = attendanceData.firstWhere(
                  (a) => a.date.year == date.year && a.date.month == date.month && a.date.day == date.day,
                  orElse: () => DailyAttendanceData(date: date, status: 'pending', wasManual: false)
                ).status;

                return _VoyageBubble(date: date, status: status);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoyageBubble extends StatelessWidget {
  final DateTime date;
  final String status;

  const _VoyageBubble({required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    final isFuture = date.isAfter(DateTime.now());

    Color color = Colors.white.withOpacity(0.08);
    if (status == 'completed_on_time') color = Colors.greenAccent;
    if (status == 'completed_late') color = Colors.amberAccent;
    if (status == 'missed') color = Colors.redAccent.withOpacity(0.5);

    return GestureDetector(
      onLongPress: () => _showDayTaskDialog(context),
      child: Container(
        width: 38, // Bigger size as requested
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(isFuture ? 0.02 : 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(isFuture ? 0.05 : 0.4),
            width: status != 'pending' ? 2 : 1,
          ),
          boxShadow: status != 'pending' && !isFuture
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)]
              : null,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              color: isFuture ? Colors.white24 : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showDayTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DayTaskDialog(date: date),
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
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}
