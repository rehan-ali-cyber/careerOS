import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/persistence/app_database.dart';
import '../../core/providers/database_provider.dart';
import 'providers/career_pilot_provider.dart';
import '../../core/theme/glass_theme.dart';

import '../../core/providers/drawer_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final pilot = ref.read(careerPilotProvider.notifier);
    _controller.clear();

    await pilot.processMessage(content);
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = ref.watch(databaseProvider).watchMessages();
    final pilotState = ref.watch(careerPilotProvider);
    final isLoading = pilotState.currentAction != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Temporarily removing local drawer to fix build and testing GlobalKey stability
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
          onPressed: () => ref.read(scaffoldKeyProvider).currentState?.openDrawer(),
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        title: const Text('Career Pilot AI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: GlassTheme.waterGradient),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading history.', style: TextStyle(color: Colors.red)));
                  }
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));

                  final messages = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isLoading) {
                        return ChatBubble(
                          message: pilotState.currentAction ?? 'Navigating...',
                          isAi: true,
                        );
                      }
                      final msg = messages[index];
                      return ChatBubble(
                        message: msg.content,
                        isAi: msg.isAi,
                      );
                    },
                  );
                },
              ),
            ),
            _GlassInputArea(
              controller: _controller,
              onSend: _sendMessage,
            ),
            const SizedBox(height: 100), // Account for floating nav bar
          ],
        ),
      ),
    );
  }
}

class _GlassInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _GlassInputArea({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => onSend(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Talk to your Career Pilot...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: onSend,
                  mini: true,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isAi;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isAi,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isAi ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAi ? 0 : 20),
            bottomRight: Radius.circular(isAi ? 20 : 0),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
