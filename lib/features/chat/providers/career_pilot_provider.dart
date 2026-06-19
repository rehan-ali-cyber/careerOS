import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/providers/settings_provider.dart';
import 'package:drift/drift.dart' as drift;

// Provider for AI Service - Following strict stability rules
final aiServiceProvider = Provider<AIService>((ref) => AIService());

class CareerPilotState {
  final bool isCalibrating;
  final bool isGeneratingRoadmap;
  final String? currentAction;

  CareerPilotState({
    this.isCalibrating = false,
    this.isGeneratingRoadmap = false,
    this.currentAction,
  });

  CareerPilotState copyWith({
    bool? isCalibrating,
    bool? isGeneratingRoadmap,
    String? currentAction,
  }) {
    return CareerPilotState(
      isCalibrating: isCalibrating ?? this.isCalibrating,
      isGeneratingRoadmap: isGeneratingRoadmap ?? this.isGeneratingRoadmap,
      currentAction: currentAction ?? this.currentAction,
    );
  }
}

class CareerPilotNotifier extends StateNotifier<CareerPilotState> {
  final AIService _ai;
  final AppDatabase _db;
  final Ref _ref;

  CareerPilotNotifier(this._ai, this._db, this._ref) : super(CareerPilotState());

  /// Build memory context from last 15 messages
  Future<String> _buildMemoryContext() async {
    final messages = await (_db.select(_db.chatMessages)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)])
          ..limit(15))
        .get();

    if (messages.isEmpty) return "";

    final history = messages.reversed.map((m) {
      final role = m.isAi ? "AI" : "User";
      return "$role: ${m.content}";
    }).join("\n");

    return "\n--- RECENT CONVERSATION HISTORY ---\n$history\n--- END OF HISTORY ---\n";
  }

  /// Process user message and handle both Normal Chat and Deep Counseling
  Future<void> processMessage(String content) async {
    // 1. Save user message
    await _db.addMessage(ChatMessagesCompanion.insert(
      content: content,
      isAi: const drift.Value(false),
    ));

    state = state.copyWith(currentAction: 'Analyzing...');

    final apiKey = _ref.read(settingsProvider).apiKey;
    final memoryContext = await _buildMemoryContext();

    // 2. Fetch current calibration context
    final calibration = await _db.select(_db.userCalibration).getSingleOrNull();
    final currentIndex = calibration?.counselingQuestionIndex ?? 0;
    final contextJson = calibration?.counselingContextJson ?? '{}';

    String prompt;

    // DECIDE MODE
    if (currentIndex > 0 && currentIndex <= 30) {
      // MODE A: DEEP COUNSELING FLOW
      prompt = '''
        $memoryContext

        USER_MESSAGE: $content
        CURRENT_QUESTION_INDEX: $currentIndex / 30
        PREVIOUS_CONTEXT: $contextJson

        CONTEXT: You are conducting a DEEP career discovery. We are on question $currentIndex of 30.
        1. Analyze the user's response and update the context.
        2. Ask the NEXT highly relevant, deep question based on their previous answers.
        3. Wrap your response in [COUNSELING] and provide the updated context and next question in JSON.
      ''';
    } else {
      // MODE B: NORMAL AI CHAT (CONCISE COACH)
      prompt = '''
        $memoryContext

        USER_MESSAGE: $content

        CONTEXT: You are a concise Career Coach. Use the history provided above for memory.
        1. Answer the user's question directly and helpfully.
        2. If they report progress on a task, start with [PROGRESS] and the task title.
        3. If they mention wanting a career change or new roadmap, suggest starting a "Deep Counseling" session.
      ''';
    }

    final aiResponse = await _ai.getResponse(prompt, apiKey);
    String cleanResponse = aiResponse;

    try {
      if (aiResponse.contains('[COUNSELING]')) {
        final jsonPart = aiResponse.split('[COUNSELING]').last.trim();
        final data = jsonDecode(jsonPart);

        await _db.update(_db.userCalibration).write(UserCalibrationCompanion(
          counselingQuestionIndex: drift.Value(currentIndex + 1),
          counselingContextJson: drift.Value(jsonEncode(data['context'])),
        ));

        cleanResponse = "Question ${currentIndex + 1}/30: ${data['nextQuestion']}";

      } else if (aiResponse.contains('[PROGRESS]')) {
        final taskTitle = aiResponse.split('[PROGRESS]').last.trim();
        final query = _db.update(_db.roadmapSteps)..where((t) => t.title.equals(taskTitle));
        await query.write(const RoadmapStepsCompanion(isCompleted: drift.Value(true)));
        cleanResponse = "Great job on completing '$taskTitle'! Keep it up!";
      }
    } catch (_) {}

    // 3. Save AI message
    await _db.addMessage(ChatMessagesCompanion.insert(
      content: cleanResponse,
      isAi: const drift.Value(true),
    ));

    state = state.copyWith(currentAction: null);
  }

  /// Start Normal Chat (Clears all messages but keeps career data)
  Future<void> startNormalChat() async {
    // 1. Wipe database table completely
    await _db.delete(_db.chatMessages).go();

    // 2. Reset counseling index to 0
    await _db.update(_db.userCalibration).write(const UserCalibrationCompanion(
      counselingQuestionIndex: drift.Value(0),
    ));

    // 3. Reset local state
    state = CareerPilotState();
  }

  /// Start Deep Counseling (Reset everything for a fresh journey)
  Future<void> startDeepCounseling() async {
    // 1. Reset all tables via DB helper
    await _db.resetCareerCounseling();

    // 2. Reset local state
    state = CareerPilotState();

    // 3. Start first discovery question
    await processMessage("Let's start my deep 30-question career counseling session.");
  }
}

final careerPilotProvider = StateNotifierProvider<CareerPilotNotifier, CareerPilotState>((ref) {
  final ai = ref.watch(aiServiceProvider);
  final db = ref.watch(databaseProvider);
  return CareerPilotNotifier(ai, db, ref);
});
