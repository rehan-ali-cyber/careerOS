import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:ui';
import '../../core/providers/database_provider.dart';
import '../../core/persistence/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_animate/flutter_animate.dart';

/**
 * VideoPlayerScreen: The elite learning sanctuary of Scholar Stream.
 * Now with MAK KHAN ROTATION: Explicitly handles sensor-based auto-rotate.
 */
class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.title
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  int _skipCount = 0;
  double _lastPosition = 0;
  int _actualSecondsWatched = 0;
  bool _isFinalized = false;

  @override
  void initState() {
    super.initState();

    // Unlock orientations to allow sensor-based rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        hideControls: false,
        useHybridComposition: true, // Smoother rotation on Android
      ),
    )..addListener(_sincerityEngine);
  }

  void _sincerityEngine() {
    if (!mounted || _isFinalized) return;

    final currentPos = _controller.value.position.inSeconds.toDouble();

    if (currentPos > _lastPosition + 3) {
      if (mounted) {
        setState(() => _skipCount++);
        _showSkipWarning();
      }
    }

    if (_controller.value.isPlaying) {
      _actualSecondsWatched++;
    }

    _lastPosition = currentPos;

    if (_controller.value.playerState == PlayerState.ended && !_isFinalized) {
      _finalizeSession();
    }
  }

  void _showSkipWarning() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("SINCERITY ALERT: Jump detected.", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _finalizeSession() async {
    if (_isFinalized) return;
    _isFinalized = true;

    final db = ref.read(databaseProvider);
    final totalDuration = _controller.metadata.duration.inSeconds;

    double score = 100.0 - (_skipCount * 4);
    if (totalDuration > 0) {
      double watchRatio = _actualSecondsWatched / totalDuration;
      if (watchRatio < 0.9) score -= (0.9 - watchRatio) * 50;
    }
    score = score.clamp(0.0, 100.0);

    try {
      await db.addVideoLog(VideoLearningLogsCompanion.insert(
        videoTitle: widget.title,
        totalDurationSeconds: totalDuration,
        watchedSeconds: _actualSecondsWatched,
        skipCount: drift.Value(_skipCount),
        sincerityScore: drift.Value(score),
      ));
    } catch (e) {
      debugPrint("Finalization Sync Error: $e");
    }
  }

  @override
  void dispose() {
    // FORCE PORTRAIT LOCK: Restore normal app orientation upon exit
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _controller.removeListener(_sincerityEngine);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.cyanAccent,
      ),
      builder: (context, player) {
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: isLandscape ? null : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_fullscreen_rounded, color: Colors.white24),
              onPressed: () async {
                await _finalizeSession();
                if (mounted) Navigator.pop(context);
              },
            ),
            title: Text(widget.title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 3, color: Colors.white24)),
          ),
          body: isLandscape
              ? Center(child: player)
              : Column(
                  children: [
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.cyanAccent.withOpacity(0.05), blurRadius: 100, spreadRadius: 10),
                        ],
                      ),
                      child: player,
                    ),
                    const SizedBox(height: 60),
                    _buildMonitorHUD(),
                    const Spacer(flex: 2),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMonitorHUD() {
    final currentScore = (100 - (_skipCount * 4)).clamp(0, 100);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _HUDNode(label: "SINCERITY", value: "$currentScore%", color: Colors.cyanAccent),
          Container(width: 1, height: 30, color: Colors.white10),
          _HUDNode(label: "SKIPS", value: "$_skipCount", color: Colors.orangeAccent),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.1);
  }
}

class _HUDNode extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HUDNode({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w100, letterSpacing: -1)),
      ],
    );
  }
}
