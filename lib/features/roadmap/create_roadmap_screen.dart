import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:ui';
import '../../core/persistence/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';

class CreateRoadmapScreen extends ConsumerStatefulWidget {
  const CreateRoadmapScreen({super.key});

  @override
  ConsumerState<CreateRoadmapScreen> createState() => _CreateRoadmapScreenState();
}

class _CreateRoadmapScreenState extends ConsumerState<CreateRoadmapScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _stepTitleControllers = [TextEditingController()];
  final List<TextEditingController> _stepDescControllers = [TextEditingController()];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var c in _stepTitleControllers) {
      c.dispose();
    }
    for (var c in _stepDescControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _stepTitleControllers.add(TextEditingController());
      _stepDescControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    if (_stepTitleControllers.length > 1) {
      setState(() {
        _stepTitleControllers[index].dispose();
        _stepDescControllers[index].dispose();
        _stepTitleControllers.removeAt(index);
        _stepDescControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveRoadmap() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a roadmap title")),
      );
      return;
    }

    final db = ref.read(databaseProvider);

    final pathId = await db.addRoadmapPath(RoadmapPathsCompanion.insert(
      title: _titleController.text,
      description: drift.Value(_descriptionController.text.isNotEmpty ? _descriptionController.text : null),
    ));

    for (int i = 0; i < _stepTitleControllers.length; i++) {
      final title = _stepTitleControllers[i].text;
      final desc = _stepDescControllers[i].text;
      if (title.isNotEmpty) {
        await db.into(db.roadmapSteps).insert(RoadmapStepsCompanion.insert(
          pathId: pathId,
          title: title,
          description: drift.Value(desc.isNotEmpty ? desc : null),
          orderIndex: i,
        ));
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("CREATE VOYAGE",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: 2)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeumorphicContainer(
            shape: BoxShape.circle,
            depth: 4,
            child: IconButton(
              icon: Icon(Icons.close, color: theme.colorScheme.onSurface, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NeumorphicContainer(
              borderRadius: 12,
              depth: 4,
              baseColor: theme.colorScheme.primary.withOpacity(0.1),
              child: TextButton(
                onPressed: _saveRoadmap,
                child: Text("SAVE",
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("General Info", theme),
              const SizedBox(height: 12),
              _buildNeumorphicTextField(_titleController,
                  "Roadmap Title (e.g. Flutter Master)", theme),
              const SizedBox(height: 12),
              _buildNeumorphicTextField(_descriptionController,
                  "Description (Optional)", theme, maxLines: 3),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle("Voyage Legs", theme),
                  NeumorphicContainer(
                    shape: BoxShape.circle,
                    depth: 4,
                    child: IconButton(
                      onPressed: _addStep,
                      icon: Icon(Icons.add_circle_outline,
                          color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _stepTitleControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildStepItem(index, theme),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.5),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildNeumorphicTextField(
      TextEditingController controller, String hint, ThemeData theme,
      {int maxLines = 1}) {
    return NeumorphicContainer(
      borderRadius: 16,
      depth: 2,
      isPressed: true,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStepItem(int index, ThemeData theme) {
    return NeumorphicContainer(
      borderRadius: 20,
      depth: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                NeumorphicContainer(
                  shape: BoxShape.circle,
                  depth: 2,
                  baseColor: theme.colorScheme.primary.withOpacity(0.1),
                  padding: const EdgeInsets.all(8),
                  child: Text("${index + 1}",
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stepTitleControllers[index],
                    style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Leg Title",
                      hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.2)),
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_stepTitleControllers.length > 1)
                  IconButton(
                    onPressed: () => _removeStep(index),
                    icon: Icon(Icons.remove_circle_outline,
                        color: Colors.redAccent.withOpacity(0.5), size: 20),
                  ),
              ],
            ),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.05)),
            TextField(
              controller: _stepDescControllers[index],
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Quick description of what to achieve...",
                hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.15)),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
