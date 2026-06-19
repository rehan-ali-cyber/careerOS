import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/persistence/app_database.dart';

/**
 * DayTaskDialog: A contextual planner for specific voyage dates.
 * Refined for stability, read-only history, and glassmorphism elegance.
 */
class DayTaskDialog extends ConsumerStatefulWidget {
  final DateTime date;
  const DayTaskDialog({super.key, required this.date});

  @override
  ConsumerState<DayTaskDialog> createState() => _DayTaskDialogState();
}

class _DayTaskDialogState extends ConsumerState<DayTaskDialog> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final dateStr = DateFormat('MMMM dd, yyyy').format(widget.date);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = widget.date.isBefore(today);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.75),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr.toUpperCase(),
              style: TextStyle(color: Colors.cyanAccent.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)
            ),
            const SizedBox(height: 4),
            Text(
              isPast ? "Historical Log" : "Day's Objectives",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w200, letterSpacing: -0.5)
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isPast) ...[
                _buildInputSection(),
                const SizedBox(height: 24),
              ],

              Flexible(
                child: StreamBuilder<List<DailyTask>>(
                  stream: db.watchTasksForDate(widget.date),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white12));
                    final tasks = snapshot.data!;

                    if (tasks.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          isPast
                            ? "NO OBJECTIVES RECORDED FOR THIS VOYAGE LEG."
                            : "NO OBJECTIVES SET FOR TODAY'S MANEUVER.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return _TaskTile(task: tasks[index], isReadOnly: isPast);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "DISMISS",
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: _taskController,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Add new objective...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.15)),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.cyanAccent, size: 20),
            onPressed: () => _saveTask(),
          ),
        ),
        onSubmitted: (_) => _saveTask(),
      ),
    );
  }

  void _saveTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    final db = ref.read(databaseProvider);
    try {
      await db.addDailyTask(DailyTasksCompanion.insert(
        date: widget.date,
        title: text,
      ));
      _taskController.clear();
    } catch (e) {
      debugPrint("Planner Sync Error: $e");
    }
  }
}

class _TaskTile extends ConsumerWidget {
  final DailyTask task;
  final bool isReadOnly;
  const _TaskTile({required this.task, required this.isReadOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: Colors.cyanAccent.withOpacity(0.2),
          checkColor: Colors.cyanAccent,
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: isReadOnly ? null : (val) {
            ref.read(databaseProvider).updateDailyTask(task.copyWith(isCompleted: val ?? false));
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: task.isCompleted ? Colors.white24 : Colors.white70,
            fontSize: 13,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: isReadOnly ? null : IconButton(
          icon: Icon(Icons.close_rounded, size: 14, color: Colors.white.withOpacity(0.05)),
          onPressed: () => ref.read(databaseProvider).deleteDailyTask(task),
        ),
      ),
    );
  }
}
