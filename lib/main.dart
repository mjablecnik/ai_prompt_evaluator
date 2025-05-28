import 'package:ai_prompt_evaluator/clients/chat_gpt_client.dart';
import 'package:ai_prompt_evaluator/prompt_evaluator.dart';
import 'package:ai_prompt_evaluator/clients/chart_client.dart';

Future<void> main(List<String> args) async {
  final promptsPath = 'prompts.json';
  final resultsDir = 'results';
  final jsonPath = '$resultsDir/evaluace.json';
  final chartPath = '$resultsDir/graf.png';

  final client = ChatGptClient();
  final evaluator = PromptEvaluator(chatGptClient: client);
  final chartClient = ChartClient();

  final prompts = await evaluator.readPrompts(promptsPath);

  final results = await evaluator.evaluatePrompts(prompts);

  await evaluator.saveResultsJson(results, jsonPath);

  await chartClient.generateChart(results, chartPath);

  print('Done. You can find the results in the $resultsDir folder.');
}
