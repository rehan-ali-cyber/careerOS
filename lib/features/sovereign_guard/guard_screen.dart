import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';

class GuardScreen extends ConsumerStatefulWidget {
  const GuardScreen({super.key});

  @override
  ConsumerState<GuardScreen> createState() => _GuardScreenState();
}

class _GuardScreenState extends ConsumerState<GuardScreen> {
  static const _channel = MethodChannel('com.example.careeros/lockdown');

  // Human-readable titles that the Native side understands specifically
  final List<String> _guardFeatures = [
    "Instagram Reels",
    "Instagram DMs",
    "YouTube Shorts",
    "Snapchat Spotlight",
    "Snapchat Chat",
  ];

  List<String> _activeBlocks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentBlocks();
  }

  Future<void> _loadCurrentBlocks() async {
    setState(() => _isLoading = true);
    try {
      final List<dynamic>? blocks = await _channel.invokeMethod('getGuardianBlocks');
      if (mounted) {
        setState(() {
          _activeBlocks = List<String>.from(blocks ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleGuardian(String feature) async {
    final newList = List<String>.from(_activeBlocks);
    if (newList.contains(feature)) newList.remove(feature);
    else newList.add(feature);

    setState(() => _activeBlocks = newList);

    try {
      await _channel.invokeMethod('saveGuardianBlocks', newList);
    } catch (e) {
      debugPrint("Failed to sync guardian: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeumorphicContainer(
            shape: BoxShape.circle,
            depth: 4,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text("SOVEREIGN GUARD", style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: 2, fontSize: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntro(theme),
              const SizedBox(height: 40),

              _buildSectionLabel("INSTAGRAM DEFENSE", theme),
              _buildGuardTile("Instagram Reels", "Blocks full-screen Reels player with black overlay", Icons.video_library_rounded, theme),
              _buildGuardTile("Instagram DMs", "Blocks direct messages with black overlay", Icons.chat_bubble_outline_rounded, theme),

              const SizedBox(height: 32),
              _buildSectionLabel("YOUTUBE DEFENSE", theme),
              _buildGuardTile("YouTube Shorts", "Blocks full-screen Shorts (30s grace period)", Icons.play_circle_outline_rounded, theme),

              const SizedBox(height: 32),
              _buildSectionLabel("SNAPCHAT DEFENSE", theme),
              _buildGuardTile("Snapchat Spotlight", "Blocks full-screen Spotlight player", Icons.flare_rounded, theme),
              _buildGuardTile("Snapchat Chat", "Blocks chat interface distraction", Icons.message_outlined, theme),

              const SizedBox(height: 60),
              _buildFooter(theme),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Surgical Warden", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -1.5)),
        const SizedBox(height: 8),
        Text(
          "No more full app blocking. We only cover the addictive content while leaving the app's navigation bar open.",
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 14),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildGuardTile(String title, String subtitle, IconData icon, ThemeData theme) {
    final isActive = _activeBlocks.contains(title);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeumorphicContainer(
        borderRadius: 24,
        depth: isActive ? 2 : 8,
        isPressed: isActive,
        baseColor: isActive ? theme.colorScheme.primary.withOpacity(0.05) : theme.scaffoldBackgroundColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: NeumorphicContainer(
            shape: BoxShape.circle,
            depth: isActive ? 1 : 4,
            isPressed: isActive,
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.24), size: 24),
          ),
          title: Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.38), fontSize: 11)),
          trailing: Switch(
            value: isActive,
            onChanged: (_) => _toggleGuardian(title),
            activeColor: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return NeumorphicContainer(
      borderRadius: 20,
      depth: 4,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.security_rounded, color: theme.colorScheme.primary.withOpacity(0.5), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Sovereign Guard uses View IDs and UI Hierarchy analysis. It does NOT rely on keywords for these surgical blocks.",
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
