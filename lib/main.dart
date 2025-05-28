import 'package:ai_prompt_evaluator/chat_gpt_client.dart';
import 'package:ai_prompt_evaluator/prompt_evaluator.dart';
import 'dart:io';

Future<void> main(List<String> args) async {
  final promptsPath = 'prompts.json';
  final resultsDir = 'results';
  final csvPath = '$resultsDir/evaluace.csv';
  final chartPath = '$resultsDir/graf.png';

  final bool generateChart = args.contains('--chart');

  final client = ChatGptClient();
  final evaluator = PromptEvaluator(chatGptClient: client);

  print('Načítám prompty z $promptsPath...');
  final prompts = await evaluator.readPrompts(promptsPath);

  print('Vyhodnocuji prompty pomocí GPT-4...');
  final results = await evaluator.evaluatePrompts(prompts);

  print('Ukládám výsledky do $csvPath...');
  await evaluator.saveResultsCsv(results, csvPath);

  if (generateChart) {
    print('Generuji graf do $chartPath...');
    await evaluator.generateChart(results, chartPath);
    print('Graf uložen.');
  }

  print('Hotovo. Výsledky najdete ve složce $resultsDir.');
}
