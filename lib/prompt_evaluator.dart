import 'dart:convert';
import 'dart:io';

import 'package:ai_prompt_evaluator/clients/chat_gpt_client.dart';

class PromptEvaluationResult {
  final String prompt;
  final String response;
  final int score;
  final String comment;

  PromptEvaluationResult({required this.prompt, required this.response, required this.score, required this.comment});

  List<String> toCsvRow() => [prompt, response, score.toString(), comment];

  Map<String, dynamic> toJson() => {'prompt': prompt, 'response': response, 'score': score, 'comment': comment};
}

class PromptEvaluator {
  final ChatGptClient chatGptClient;

  PromptEvaluator({required this.chatGptClient});

  /// Reads prompts from a JSON file (expects a list of strings).
  Future<List<String>> readPrompts(String path) async {
    print('Loading prompts from $path...');
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File not found: $path');
    }
    final content = await file.readAsString();
    final data = jsonDecode(content);
    if (data is! List) {
      throw Exception('Invalid prompts.json format: expected a list of strings.');
    }
    return data.cast<String>();
  }

  /// Evaluates all prompts, returns a list of results.
  Future<List<PromptEvaluationResult>> evaluatePrompts(List<String> prompts) async {
    print('Evaluating prompts using GPT-4...');
    final results = <PromptEvaluationResult>[];
    for (final prompt in prompts) {
      final response = await chatGptClient.query(prompt, model: 'gpt-4');
      final score = await _autoScore(prompt, response);
      final comment = await _autoComment(prompt, response);
      results.add(PromptEvaluationResult(prompt: prompt, response: response, score: score, comment: comment));
    }
    return results;
  }

  /// Saves results to a JSON file.
  Future<void> saveResultsJson(List<PromptEvaluationResult> results, String path) async {
    print('Saving results to $path...');
    final file = File(path);
    await file.parent.create(recursive: true);
    final jsonList = results.map((r) => r.toJson()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
    await file.writeAsString(jsonString);
  }

  /// Uses GPT-4 to auto-score the response (0-5).
  Future<int> _autoScore(String prompt, String response) async {
    final scoringPrompt =
        'Ohodnoť následující odpověď na prompt na škále 0–5, kde 5 je perfektní, 0 je zcela špatně. '
        'Odpověz pouze číslem.\n\nPROMPT:\n$prompt\n\nODPOVĚĎ:\n$response';
    final scoreStr = await chatGptClient.query(scoringPrompt, model: 'gpt-4');
    final match = RegExp(r'\d').firstMatch(scoreStr);
    if (match != null) {
      if (match.group(0) == null) {
        throw Exception('Could not parse score from response: $scoreStr');
      }
      return int.parse(match.group(0)!);
    }
    return 0;
  }

  /// Uses GPT-4 to generate a comment about what is good, bad, or missing.
  Future<String> _autoComment(String prompt, String response) async {
    final commentPrompt =
        'Zhodnoť následující odpověď na prompt. Napiš, co je dobře, co špatně nebo co chybí. '
        'Piš česky.\n\nPROMPT:\n$prompt\n\nODPOVĚĎ:\n$response';
    return await chatGptClient.query(commentPrompt, model: 'gpt-4');
  }
}
