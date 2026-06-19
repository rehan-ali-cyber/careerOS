import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiVersion = 'v1';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/$_apiVersion';

  GenerativeModel? _cachedModel;
  String? _lastUsedApiKey;
  bool _isDiscoveryAttempted = false;
  bool _isDiscoveryFailed = false;

  /// System Health Check
  Future<Map<String, dynamic>> checkHealth(String apiKey) async {
    if (apiKey.isEmpty) return {'status': 'MISSING_KEY', 'message': 'API Key not set'};

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models?key=$apiKey'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return {'status': 'READY', 'message': 'AI Engine Online'};
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        return {'status': 'INVALID_KEY', 'message': 'Invalid API Key'};
      } else {
        return {'status': 'SERVER_ERROR', 'message': 'API Error (${response.statusCode})'};
      }
    } catch (e) {
      return {'status': 'OFFLINE', 'message': 'Network unreachable'};
    }
  }

  /// Dynamic Model Discovery
  Future<bool> _ensureInitialized(String apiKey) async {
    if (_lastUsedApiKey != apiKey) {
      _cachedModel = null;
      _isDiscoveryAttempted = false;
      _isDiscoveryFailed = false;
    }

    if (_cachedModel != null) return true;
    if (_isDiscoveryFailed && _lastUsedApiKey == apiKey) return false;
    if (_isDiscoveryAttempted && _lastUsedApiKey == apiKey) return false;

    _lastUsedApiKey = apiKey;
    _isDiscoveryAttempted = true;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models?key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List modelsList = data['models'] ?? [];

        final List validModels = modelsList.where((m) {
          final List methods = m['supportedGenerationMethods'] ?? [];
          return methods.contains('generateContent');
        }).toList();

        if (validModels.isEmpty) {
          _isDiscoveryFailed = true;
          return false;
        }

        String? targetModel;
        for (final m in validModels) {
          final String name = m['name'] ?? '';
          if (name.toLowerCase().contains('flash')) {
            targetModel = name;
            break;
          }
        }

        if (targetModel == null) {
          for (final m in validModels) {
            final String name = m['name'] ?? '';
            if (name.toLowerCase().contains('pro')) {
              targetModel = name;
              break;
            }
          }
        }

        targetModel ??= validModels.first['name'] as String;

        _cachedModel = GenerativeModel(
          model: targetModel,
          apiKey: apiKey,
          requestOptions: const RequestOptions(apiVersion: _apiVersion),
        );
        return true;
      }
    } catch (_) {}

    _isDiscoveryFailed = true;
    return false;
  }

  /// Production-grade Response with Retry for 503
  Future<String> getResponse(String prompt, String apiKey) async {
    if (apiKey.isEmpty) {
      return 'Please set your Gemini API Key in the Profile section to use AI features.';
    }

    int attempts = 0;
    const int maxAttempts = 3;
    final List<int> backoffs = [2000, 4000, 8000];

    while (attempts < maxAttempts) {
      try {
        final ready = await _ensureInitialized(apiKey);
        if (!ready || _cachedModel == null) return 'AI service unavailable. Check your API key or connection.';

        final content = [Content.text('As a career coach, be concise. Answer this: $prompt')];
        final response = await _cachedModel!.generateContent(content);

        final text = response.text;
        if (text == null || text.isEmpty) return 'No response generated.';
        return text;
      } catch (e) {
        final errorStr = e.toString().toLowerCase();

        if (errorStr.contains('403') || errorStr.contains('permission') || errorStr.contains('api key not valid')) {
          return 'Your API Key seems invalid. Please check it in the Profile section.';
        }

        if (errorStr.contains('503') || errorStr.contains('high demand') || errorStr.contains('unavailable')) {
          if (attempts < maxAttempts - 1) {
            await Future.delayed(Duration(milliseconds: backoffs[attempts]));
            attempts++;
            continue;
          }
          return _getMockFallback(prompt);
        }

        return 'I encountered a connection issue. Please check your API key and try again.';
      }
    }
    return _getMockFallback(prompt);
  }

  String _getMockFallback(String prompt) {
    return "The AI is currently under high demand. I'm operating in 'Offline Coach' mode. How can I help with your career goals today?";
  }
}
