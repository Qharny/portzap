import 'dart:io';
import 'package:args/args.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('port', abbr: 'p', help: 'Port number to kill')
    ..addFlag('list', abbr: 'l', negatable: false, help: 'List all running ports')
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

  if (argResults['list']) {
    await listPorts();
    exit(0);
  }

  final port = argResults['port'];
  if (port == null) {
    print('Error: Port number is required when not using --list.');
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
  print('Usage: dart port_killer.dart [-p <port_number> | -l]');
  print(parser.usage);
}

Future<void> listPorts() async {
  String command;
  List<String> arguments;

  if (Platform.isWindows) {
    command = 'netstat';
    arguments = ['-ano'];
  } else if (Platform.isMacOS || Platform.isLinux) {
    command = 'lsof';
    arguments = ['-i', '-P', '-n'];
  } else {
    throw 'Unsupported platform: ${Platform.operatingSystem}';
  }

  final result = await Process.run(command, arguments, runInShell: true);

  if (result.exitCode != 0) {
    throw 'Failed to list ports: ${result.stderr}';
  }

  final output = result.stdout.toString().trim();
  final lines = output.split('\n');

  print('List of running ports:');
  print('----------------------');

  if (Platform.isWindows) {
    for (var line in lines.skip(4)) {
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        final address = parts[1].split(':');
        if (address.length == 2) {
          print('Port: ${address[1].padRight(5)} | PID: ${parts.last}');
        }
      }
    }
  } else {
    for (var line in lines.skip(1)) {
      if (line.contains('LISTEN')) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length >= 9) {
          final address = parts[8].split(':');
          if (address.length == 2) {
            print('Port: ${address[1].padRight(5)} | PID: ${parts[1]}');
          }
        }
      }
    }
  }
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