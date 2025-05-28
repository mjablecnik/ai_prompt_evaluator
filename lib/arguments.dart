import 'package:vader_console/vader_console.dart';

List<Command> commands = [
  Command(
    flag: 'm',
    name: 'message',
    commandType: CommandType.option,
    commandHelp: 'Print message.',
  ),
  ...CoreCommands.list,
];

class CliArguments extends Arguments {
  CliArguments({
    required super.showVersion,
    required super.showHelp,
    required super.isVerbose,
    this.message,
  });

  final String? message;

  static CliArguments parse(List<String> arguments, List<Command> commands) {
    final results = ArgumentParser(commands).parse(arguments);
    return CliArguments(
      showHelp: results.wasParsed(CoreCommands.help.name),
      isVerbose: results.wasParsed(CoreCommands.verbose.name),
      showVersion: results.wasParsed(CoreCommands.version.name),
      message: Arguments.getOptionOrNull(results, option: "message"),
    );
  }
}
