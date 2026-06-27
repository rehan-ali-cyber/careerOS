import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:drift/drift.dart' as drift;
import '../../core/persistence/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../chat/providers/career_pilot_provider.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';
import '../../core/providers/drawer_provider.dart';
import 'roadmap_track_screen.dart';
import 'create_roadmap_screen.dart';

class RoadmapScreen extends ConsumerWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.roadmap, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0), // Lift above the custom glass nav bar
        child: NeumorphicContainer(
          shape: BoxShape.circle,
          depth: 10,
          baseColor: theme.colorScheme.primary,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateRoadmapScreen()),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(Icons.add, color: theme.brightness == Brightness.dark ? Colors.black : Colors.white),
          ),
        ),
      ),
      body: StreamBuilder<List<RoadmapPath>>(
        stream: db.watchRoadmapPaths(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final paths = snapshot.data!;
          if (paths.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          return _RoadmapListView(paths: paths);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 20),
            Text(
              "Ready to start your journey as a ${settings.targetCareer}?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 10),
            Text(
              "Manually create your custom voyage track to reach your goals.",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 30),
            NeumorphicContainer(
              borderRadius: 24,
              depth: 8,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: theme.colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateRoadmapScreen()),
                  );
                },
                icon: Icon(Icons.add_road_rounded, color: theme.colorScheme.primary),
                label: const Text("Create Your First Voyage"),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(),
    );
  }

  void _createDemoDSARoadmap(WidgetRef ref) async {
    final db = ref.read(databaseProvider);

    // 1. Create Path
    final pathId = await db.addRoadmapPath(RoadmapPathsCompanion.insert(
      title: "DSA Mastery: 6 Month Voyage",
      description: const drift.Value("Structured track from Basics to Advanced Algorithms"),
    ));

    // 2. Define 6 Months of stops
    final demoSteps = [
      {"t": "Month 1: Language Basics & Complexity", "d": "Master your chosen language and Big O notation."},
      {"t": "Month 2: Linear Data Structures", "d": "Arrays, Linked Lists, Stacks, and Queues."},
      {"t": "Month 3: Searching & Sorting", "d": "Binary Search, Quick Sort, Merge Sort, and Recursion."},
      {"t": "Month 4: Non-Linear Structures", "d": "Trees, Heaps, and Hashing techniques."},
      {"t": "Month 5: Advanced Algorithms", "d": "Graphs (BFS/DFS) and Dynamic Programming basics."},
      {"t": "Month 6: Interview Grind", "d": "System Design basics and 100+ LeetCode problems."},
    ];

    for (int i = 0; i < demoSteps.length; i++) {
      await db.into(db.roadmapSteps).insert(RoadmapStepsCompanion.insert(
        pathId: pathId,
        title: demoSteps[i]["t"]!,
        description: drift.Value(demoSteps[i]["d"]),
        orderIndex: i,
      ));
    }
  }
}

class _RoadmapListView extends StatelessWidget {
  final List<RoadmapPath> paths;
  const _RoadmapListView({required this.paths});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 100),
      physics: const BouncingScrollPhysics(),
      itemCount: paths.length,
      itemBuilder: (context, index) {
        final path = paths[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _RoadmapCard(path: path),
        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
      },
    );
  }
}

class _RoadmapCard extends ConsumerWidget {
  final RoadmapPath path;
  const _RoadmapCard({required this.path});

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text("Delete Voyage?", style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text("Are you sure you want to delete '${path.title}'?", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3))),
          ),
          TextButton(
            onPressed: () {
              ref.read(databaseProvider).deleteRoadmapPath(path.id);
              Navigator.pop(context);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 28,
      depth: 8,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoadmapTrackScreen(path: path),
            ),
          );
        },
        onLongPress: () => _showDeleteDialog(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              NeumorphicContainer(
                shape: BoxShape.circle,
                depth: 4,
                baseColor: theme.colorScheme.primary.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.route_rounded, color: theme.colorScheme.primary, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      path.title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tap to view voyage track",
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.onSurface.withOpacity(0.2), size: 20),
                onPressed: () => _showDeleteDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
