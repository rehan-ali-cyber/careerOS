import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  GeminiService({required this.apiKey});

  final String apiKey;

  String? _cachedModel;

  bool _isFetchingModel = false;

  // ─────────────────────────────
  // 1. FETCH MODELS SAFELY
  // ─────────────────────────────
  Future<String?> _getValidModel() async {
    if (_cachedModel != null) return _cachedModel;

    if (_isFetchingModel) {
      // prevent parallel calls
      await Future.delayed(const Duration(milliseconds: 300));
      return _cachedModel;
    }

    _isFetchingModel = true;

    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models?key=$apiKey",
      );

      final res = await http.get(url);

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);

      final models = data['models'] as List<dynamic>?;

      if (models == null || models.isEmpty) return null;

      for (final m in models) {
        final name = m['name'] ?? '';

        // Prefer best available models
        if (name.contains("flash") || name.contains("pro")) {
          _cachedModel = name;
          return _cachedModel;
        }
      }

      // fallback: first available model
      _cachedModel = models.first['name'];
      return _cachedModel;
    } catch (_) {
      return null;
    } finally {
      _isFetchingModel = false;
    }
  }

  // ─────────────────────────────
  // 2. MAIN GENERATION METHOD
  // ─────────────────────────────
  Future<String> generate(String prompt) async {
    try {
      final model = await _getValidModel();

      if (model == null) {
        return "AI service unavailable. Please try again later.";
      }

      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/$model:generateContent?key=$apiKey",
      );

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      };

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) {
        return "AI error occurred. Please retry.";
      }

      final data = jsonDecode(res.body);

      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      if (text == null) {
        return "No response generated.";
      }

      return text;
    } catch (_) {
      return "Something went wrong. Please try again.";
    }
  }

  // ─────────────────────────────
  // 3. SAFE RETRY WRAPPER
  // ─────────────────────────────
  Future<String> generateWithRetry(String prompt) async {
    final first = await generate(prompt);

    // simple retry ONLY once if failure text
    if (first.contains("error") || first.contains("unavailable")) {
      await Future.delayed(const Duration(milliseconds: 500));
      return await generate(prompt);
    }

    return first;
  }
}