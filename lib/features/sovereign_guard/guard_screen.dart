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

  // Logic: Map human-readable toggles to specific sets of keywords
  final Map<String, List<String>> _guardianRules = {
    "Instagram Reels": ["reels", "reels tab", "explore", "video", "audio"],
    "Instagram DMs": ["messages", "chats", "direct", "requests"],
    "YouTube Shorts": ["shorts", "shorts tab", "trending", "explore"],
    "Snapchat Spotlight": ["spotlight", "discover", "stories"],
    "Snapchat Chat": ["chats", "messages", "friends"],
  };

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
      final List<dynamic>? keywords = await _channel.invokeMethod('getBlockedKeywords');
      final currentKeywords = List<String>.from(keywords ?? []);

      List<String> active = [];
      _guardianRules.forEach((key, words) {
        // If ALL keywords for a rule are present, mark as active
        if (words.every((w) => currentKeywords.contains(w.toLowerCase()))) {
          active.add(key);
        }
      });

      if (mounted) {
        setState(() {
          _activeBlocks = active;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleGuardian(String ruleKey) async {
    final newList = List<String>.from(_activeBlocks);
    final bool turningOn = !newList.contains(ruleKey);

    if (turningOn) newList.add(ruleKey);
    else newList.remove(ruleKey);

    setState(() => _activeBlocks = newList);

    // Update native keywords
    try {
      final List<dynamic>? currentKeywordsRaw = await _channel.invokeMethod('getBlockedKeywords');
      final currentKeywords = List<String>.from(currentKeywordsRaw ?? []);

      final targetWords = _guardianRules[ruleKey]!;

      if (turningOn) {
        for (var w in targetWords) {
          if (!currentKeywords.contains(w.toLowerCase())) currentKeywords.add(w.toLowerCase());
        }
      } else {
        // Only remove if they aren't part of ANOTHER active block
        for (var w in targetWords) {
          bool keep = false;
          _activeBlocks.forEach((otherKey) {
            if (otherKey != ruleKey && _guardianRules[otherKey]!.contains(w)) keep = true;
          });
          if (!keep) currentKeywords.remove(w.toLowerCase());
        }
      }

      await _channel.invokeMethod('saveBlockedKeywords', currentKeywords);
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
              _buildGuardTile("Instagram Reels", "Blocks vertical scrolling addictive content", Icons.video_library_rounded, theme),
              _buildGuardTile("Instagram DMs", "Blocks distraction from direct messaging", Icons.chat_bubble_outline_rounded, theme),

              const SizedBox(height: 32),
              _buildSectionLabel("YOUTUBE DEFENSE", theme),
              _buildGuardTile("YouTube Shorts", "Blocks addictive short-form video tab", Icons.play_circle_outline_rounded, theme),

              const SizedBox(height: 32),
              _buildSectionLabel("SNAPCHAT DEFENSE", theme),
              _buildGuardTile("Snapchat Spotlight", "Blocks spotlight scrolling & stories", Icons.flare_rounded, theme),
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
        Text("In-App Warden", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -1.5)),
        const SizedBox(height: 8),
        Text(
          "Surgical precision blocking for specific app features. Kill the addiction, keep the utility.",
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
              "Accessibility Service is actively monitoring system UI to enforce these surgical blocks.",
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
