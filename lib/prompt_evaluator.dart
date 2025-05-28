import 'dart:convert';
import 'dart:io';

import 'package:ai_prompt_evaluator/chat_gpt_client.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';

class PromptEvaluationResult {
  final String prompt;
  final String response;
  final int score;
  final String comment;

  PromptEvaluationResult({
    required this.prompt,
    required this.response,
    required this.score,
    required this.comment,
  });

  List<String> toCsvRow() => [prompt, response, score.toString(), comment];
}

class PromptEvaluator {
  final ChatGptClient chatGptClient;

  PromptEvaluator({required this.chatGptClient});

  /// Reads prompts from a JSON file (expects a list of strings).
  Future<List<String>> readPrompts(String path) async {
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
    final results = <PromptEvaluationResult>[];
    for (final prompt in prompts) {
      final response = await chatGptClient.query(prompt, model: 'gpt-4');
      final score = await _autoScore(prompt, response);
      final comment = await _autoComment(prompt, response);
      results.add(PromptEvaluationResult(
        prompt: prompt,
        response: response,
        score: score,
        comment: comment,
      ));
    }
    return results;
  }

  /// Saves results to a CSV file.
  Future<void> saveResultsCsv(List<PromptEvaluationResult> results, String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final rows = [
      ['Prompt', 'Response', 'Score', 'Comment'],
      ...results.map((r) => r.toCsvRow()),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
  }

  /// Generates a bar chart using QuickChart.io and saves it as a PNG.
  Future<void> generateChart(List<PromptEvaluationResult> results, String path) async {
    final labels = results.asMap().keys.map((i) => 'P${i + 1}').toList();
    final scores = results.map((r) => r.score).toList();

    final chartConfig = {
      'type': 'bar',
      'data': {
        'labels': labels,
        'datasets': [
          {
            'label': 'Score',
            'data': scores,
            'backgroundColor': 'rgba(54, 162, 235, 0.7)',
          }
        ]
      },
      'options': {
        'scales': {
          'y': {
            'beginAtZero': true,
            'max': 5,
          }
        }
      }
    };

    final url = 'https://quickchart.io/chart';
    final dio = Dio();
    final response = await dio.get(
      url,
      queryParameters: {
        'c': jsonEncode(chartConfig),
        'format': 'png',
        'width': 600,
        'height': 400,
        'backgroundColor': 'white',
      },
      options: Options(responseType: ResponseType.bytes),
    );

    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(response.data);
  }

  /// Uses GPT-4 to auto-score the response (0-5).
  Future<int> _autoScore(String prompt, String response) async {
    final scoringPrompt = '''
Ohodnoť následující odpověď na prompt na škále 0–5, kde 5 je perfektní, 0 je zcela špatně. Odpověz pouze číslem.

PROMPT:
$prompt

ODPOVĚĎ:
$response
''';
    final scoreStr = await chatGptClient.query(scoringPrompt, model: 'gpt-4');
    final match = RegExp(r'\d').firstMatch(scoreStr);
    if (match != null) {
      return int.parse(match.group(0)!);
    }
    return 0;
  }

  /// Uses GPT-4 to generate a comment about what is good, bad, or missing.
  Future<String> _autoComment(String prompt, String response) async {
    final commentPrompt = '''
Zhodnoť následující odpověď na prompt. Napiš, co je dobře, co špatně nebo co chybí. Piš česky.

PROMPT:
$prompt

ODPOVĚĎ:
$response
''';
    return await chatGptClient.query(commentPrompt, model: 'gpt-4');
  }
}
