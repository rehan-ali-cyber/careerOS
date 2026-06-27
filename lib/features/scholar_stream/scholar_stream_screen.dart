import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../core/widgets/beautiful_background.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';
import '../../core/providers/drawer_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/persistence/app_database.dart';
import '../../core/services/youtube_api_service.dart';
import 'video_player_screen.dart';

/**
 * ScholarStreamScreen: The Distraction-Free Learning Hub.
 * Optimized with the final 'Supreme Edition' polish.
 */
class ScholarStreamScreen extends ConsumerStatefulWidget {
  const ScholarStreamScreen({super.key});

  @override
  ConsumerState<ScholarStreamScreen> createState() => _ScholarStreamScreenState();
}

class _ScholarStreamScreenState extends ConsumerState<ScholarStreamScreen> {
  final TextEditingController _linkController = TextEditingController();
  List<Map<String, String>> _videos = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _processPlaylist() async {
    final url = _linkController.text.trim();
    final playlistId = YoutubeApiService.extractPlaylistId(url);

    if (playlistId == null) {
      _showToast("INVALID VOYAGE ID");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final videos = await YoutubeApiService.fetchPlaylistVideos(playlistId);
      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
        _showToast("SYNCED ${videos.length} KNOWLEDGE NODES");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showToast("LINK FAILED: SECURE ENCRYPTED");
      }
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeumorphicContainer(
            shape: BoxShape.circle,
            depth: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text("SCHOLAR STREAM", style: TextStyle(fontWeight: FontWeight.w200, letterSpacing: 5, fontSize: 13, color: Colors.white24)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildLinkInput(),
              const SizedBox(height: 40),

              _buildSectionLabel("MISSION ANALYTICS"),
              _buildLearningLedgerCard(),

              const SizedBox(height: 32),
              _buildSectionLabel(_videos.isEmpty ? "VOYAGE CHANNELS" : "VOYAGE SYLLABUS"),

              if (_isLoading)
                const _LoadingVessel()
              else if (_videos.isEmpty)
                _buildDemoButton()
              else
                ..._videos.map((v) => _VideoModuleTile(video: v)),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.15),
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 3
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Scholar Stream",
          style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2),
        ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.05),
        const SizedBox(height: 4),
        Text(
          "ENGAGE IN DEEP STUDY WITHOUT DISTRACTION.",
          style: TextStyle(fontSize: 10, color: Colors.cyanAccent.withOpacity(0.5), fontWeight: FontWeight.w800, letterSpacing: 2),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildLinkInput() {
    return NeumorphicContainer(
      borderRadius: 24,
      depth: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.hub_outlined, color: Colors.white12, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: NeumorphicContainer(
                borderRadius: 16,
                isPressed: true,
                depth: 2,
                child: TextField(
                  controller: _linkController,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300),
                  decoration: const InputDecoration(
                    hintText: "PASTE PLAYLIST LINK...",
                    hintStyle: TextStyle(color: Colors.white10, fontSize: 12, letterSpacing: 1),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => _processPlaylist(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            NeumorphicContainer(
              shape: BoxShape.circle,
              depth: 4,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.cyanAccent, size: 20),
                onPressed: () => _processPlaylist(),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.98, 0.98));
  }

  Widget _buildLearningLedgerCard() {
    final logsStream = ref.watch(databaseProvider).watchVideoLogs();

    return StreamBuilder<List<VideoLearningLog>>(
      stream: logsStream,
      builder: (context, snapshot) {
        final totalVideos = snapshot.data?.length ?? 0;
        double avgSincerity = 0.0;
        if (totalVideos > 0) {
          avgSincerity = snapshot.data!.map((e) => e.sincerityScore).reduce((a, b) => a + b) / totalVideos;
        }

        return NeumorphicContainer(
          borderRadius: 30,
          depth: 10,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                _CircularStat(label: "TOTAL LOGS", value: "$totalVideos"),
                const Spacer(),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.05)),
                const Spacer(),
                _CircularStat(label: "AVG SINCERITY", value: "${avgSincerity.toInt()}%", color: Colors.cyanAccent),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05);
  }

  Widget _buildDemoButton() {
    return NeumorphicContainer(
      borderRadius: 24,
      depth: 8,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => const VideoPlayerScreen(
                videoId: "n2RNcPRtAiY",
                title: "Cinematic Voyage Primer",
              )
            )
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              NeumorphicContainer(
                shape: BoxShape.circle,
                depth: 4,
                baseColor: Colors.amber.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.amber, size: 28),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("DEMO VOYAGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                    Text("TEST THE SINCERITY ENGINE", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoModuleTile extends StatelessWidget {
  final Map<String, String> video;
  const _VideoModuleTile({required this.video});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeumorphicContainer(
        borderRadius: 20,
        depth: 6,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => VideoPlayerScreen(
                  videoId: video['id']!,
                  title: video['title']!,
                )
              )
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                NeumorphicContainer(
                  borderRadius: 16,
                  depth: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(video['thumbnail']!, width: 100, height: 60, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video['title']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text("READY FOR FOCUS", style: TextStyle(color: Colors.cyanAccent.withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.1)),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }
}


class _LoadingVessel extends StatelessWidget {
  const _LoadingVessel();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 1),
          const SizedBox(height: 20),
          Text("DEEP SCANNING SYLLABUS...", style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 9, letterSpacing: 3, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _CircularStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _CircularStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white10, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 32, fontWeight: FontWeight.w100, letterSpacing: -1)),
      ],
    );
  }
}
