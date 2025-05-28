import 'package:ai_prompt_evaluator/chat_gpt_client.dart';
import 'package:vader_console/vader_console.dart';
import 'package:ai_prompt_evaluator/arguments.dart';

void main(List<String> args) {
  runCliApp(
    arguments: args,
    commands: commands,
    parser: CliArguments.parse,
    app: (args) async {
      print("Main part of my app...");
      print("Message: ${args.message}");
      final client = ChatGptClient();
      final result = await client.query(args.message!);
      print(result);
    },
  );
}
