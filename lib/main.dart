import 'package:ai_prompt_evaluator/clients/chat_gpt_client.dart';
import 'package:ai_prompt_evaluator/prompt_evaluator.dart';
import 'package:ai_prompt_evaluator/clients/chart_client.dart';
import 'package:args/args.dart';

Future<void> main(List<String> args) async {
  // Setup args parser
  final parser = ArgParser()
    ..addOption('input', abbr: 'i', help: 'Path to prompts JSON file', defaultsTo: 'prompts.json')
    ..addOption('output', abbr: 'o', help: 'Directory to save results', defaultsTo: 'results');

  final argResults = parser.parse(args);

  // Setup variables
  final promptsPath = argResults['input'] as String;
  final resultsDir = argResults['output'] as String;
  final jsonPath = '$resultsDir/evaluation.json';
  final chartPath = '$resultsDir/graph.png';

  // Setup clients
  final client = ChatGptClient();
  final evaluator = PromptEvaluator(chatGptClient: client);
  final chartClient = ChartClient();

  // Main logic
  final prompts = await evaluator.readPrompts(promptsPath);
  final results = await evaluator.evaluatePrompts(prompts);
  await evaluator.saveResultsJson(results, jsonPath);
  await chartClient.generateChart(results, chartPath);

  print('Done. You can find the results in the $resultsDir folder.');
}
