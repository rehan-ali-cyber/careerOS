import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/persistence/app_database.dart';
import '../../core/providers/database_provider.dart';
import 'providers/career_pilot_provider.dart';
import '../../core/widgets/neomorphic/neumorphic_container.dart';
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
      backgroundColor: const Color(0xFF1A1A1A),
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
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
              onPressed: () => ref.read(scaffoldKeyProvider).currentState?.openDrawer(),
            ),
          ),
        ),
        title: const Text('Career Pilot AI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(
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
          _NeumorphicInputArea(
            controller: _controller,
            onSend: _sendMessage,
          ),
          const SizedBox(height: 100), // Account for floating nav bar
        ],
      ),
    );
  }
}

class _NeumorphicInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _NeumorphicInputArea({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: NeumorphicContainer(
        borderRadius: 32,
        depth: 6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: NeumorphicContainer(
                  borderRadius: 24,
                  isPressed: true,
                  depth: 2,
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
              ),
              const SizedBox(width: 12),
              NeumorphicContainer(
                shape: BoxShape.circle,
                depth: 4,
                child: FloatingActionButton(
                  onPressed: onSend,
                  mini: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  child: const Icon(Icons.send, color: Colors.cyanAccent),
                ),
              ),
            ],
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: NeumorphicContainer(
          borderRadius: 20,
          depth: 4,
          baseColor: isAi ? const Color(0xFF202020) : const Color(0xFF1A1A1A),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
