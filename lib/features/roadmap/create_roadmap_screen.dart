import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:ui';
import '../../core/persistence/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/beautiful_background.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("CREATE VOYAGE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveRoadmap,
            child: const Text("SAVE", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: BeautifulBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("General Info"),
                  const SizedBox(height: 12),
                  _buildGlassTextField(_titleController, "Roadmap Title (e.g. Flutter Master)"),
                  const SizedBox(height: 12),
                  _buildGlassTextField(_descriptionController, "Description (Optional)", maxLines: 3),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Voyage Legs"),
                      IconButton(
                        onPressed: _addStep,
                        icon: const Icon(Icons.add_circle_outline, color: Colors.cyanAccent),
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
                        child: _buildStepItem(index),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildGlassTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                child: Text("${index + 1}", style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _stepTitleControllers[index],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Leg Title",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_stepTitleControllers.length > 1)
                IconButton(
                  onPressed: () => _removeStep(index),
                  icon: Icon(Icons.remove_circle_outline, color: Colors.redAccent.withOpacity(0.5), size: 20),
                ),
            ],
          ),
          const Divider(color: Colors.white10),
          TextField(
            controller: _stepDescControllers[index],
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Quick description of what to achieve...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.15)),
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
