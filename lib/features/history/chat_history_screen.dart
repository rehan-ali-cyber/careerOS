import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/persistence/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/theme/glass_theme.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesStream = ref.watch(databaseProvider).watchMessages();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Chat Logs', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: GlassTheme.waterGradient),
        child: StreamBuilder<List<ChatMessage>>(
          stream: messagesStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));

            final messages = snapshot.data!;

            if (messages.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 40),
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _HistoryChatBubble(message: msg);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "No chat history found.",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _HistoryChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _HistoryChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isAi = message.isAi;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isAi ? Colors.white.withOpacity(0.08) : Colors.cyanAccent.withOpacity(0.15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAi ? 0 : 16),
            bottomRight: Radius.circular(isAi ? 16 : 0),
          ),
          border: Border.all(
            color: isAi ? Colors.white.withOpacity(0.1) : Colors.cyanAccent.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAi ? "Career Pilot" : "You",
              style: TextStyle(
                color: isAi ? Colors.white54 : Colors.cyanAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
