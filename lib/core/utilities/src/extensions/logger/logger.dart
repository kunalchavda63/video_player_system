import 'dart:convert';

import 'package:logger/logger.dart';

void printPrettyLog(String message) {
  // const reset = '\x1B[0m';
  // const bold = '\x1B[1m';
  // const red = '\x1B[31m';
  // const green = '\x1B[32m';
  // const yellow = '\x1B[33m';
  // const blue = '\x1B[34m';
  // const magenta = '\x1B[35m';
  // const cyan = '\x1B[36m';

  // print('$bold$blue ┌──────────────────────────────┐$reset');
  // print('$bold$green│ LOG START                    │$reset');
  // print('$bold$cyan │ $message                     │$reset');
  // print('$bold$red  │ LOG END                      │$reset');
  // print('$bold$blue └──────────────────────────────┘$reset');
}

final logger = Logger(
  printer: PrettyPrinter(
    lineLength: 400,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

void logModelBox(String title, dynamic data) {
  logger.i('''
╔══════════════════════════════════════════════════╗
║ $title                                  
╟──────────────────────────────────────────────────╢
║ ${_prettyJson(data)}                             
╚══════════════════════════════════════════════════╝
''');
}

String _prettyJson(dynamic data) {
  if (data is Map || data is List) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } on Exception catch (_) {
      return data.toString();
    }
  }
  return data.toString();
}