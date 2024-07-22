import 'dart:io';
import 'package:args/args.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('port', abbr: 'p', help: 'Port number to kill')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage information');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print('Error: ${e.toString()}');
    printUsage(parser);
    exit(1);
  }

  if (argResults['help']) {
    printUsage(parser);
    exit(0);
  }

  final port = argResults['port'];
  if (port == null) {
    print('Error: Port number is required.');
    printUsage(parser);
    exit(1);
  }

  try {
    await killPort(int.parse(port));
  } catch (e) {
    print('Error: ${e.toString()}');
    exit(1);
  }
}

void printUsage(ArgParser parser) {
  print('Usage: dart port_killer.dart -p <port_number>');
  print(parser.usage);
}

Future<void> killPort(int port) async {
  String command;
  List<String> arguments;

  if (Platform.isWindows) {
    command = 'netstat';
    arguments = ['-ano', '|', 'findstr', ':$port'];
  } else if (Platform.isMacOS || Platform.isLinux) {
    command = 'lsof';
    arguments = ['-i', ':$port', '-t'];
  } else {
    throw 'Unsupported platform: ${Platform.operatingSystem}';
  }

  final result = await Process.run(command, arguments, runInShell: true);

  if (result.exitCode != 0) {
    throw 'Failed to find process on port $port';
  }

  final output = result.stdout.toString().trim();
  if (output.isEmpty) {
    print('No process found running on port $port');
    return;
  }

  int? pid;
  if (Platform.isWindows) {
    pid = int.tryParse(output.split('\r\n').last.trim().split(' ').last);
  } else {
    pid = int.tryParse(output.split('\n').first.trim());
  }

  if (pid == null) {
    throw 'Failed to extract PID from command output';
  }

  final killCommand = Platform.isWindows ? 'taskkill' : 'kill';
  final killArgs = Platform.isWindows ? ['/F', '/PID', '$pid'] : ['-9', '$pid'];

  final killResult = await Process.run(killCommand, killArgs);

  if (killResult.exitCode == 0) {
    print('Successfully killed process $pid running on port $port');
  } else {
    throw 'Failed to kill process $pid: ${killResult.stderr}';
  }
}