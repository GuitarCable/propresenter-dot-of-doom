import 'dart:io';
import 'package:logging/logging.dart';

Future<void> setupLoggingPath(String filePath) async {
  // Extract the directory path from the file path
  String directoryPath = filePath.substring(0, filePath.lastIndexOf('/'));

  // Create the directory recursively if it doesn't exist
  Directory directory = Directory(directoryPath);
  if (!(await directory.exists())) {
    await directory.create(recursive: true);
    print('Directory created: ${directory.path}');
  } else {
    print('Directory already exists: ${directory.path}');
  }

  // Create the file if it doesn't exist
  File file = File(filePath);
  if (!(await file.exists())) {
    await file.create();
    print('File created: ${file.path}');
  } else {
    print('File already exists: ${file.path}');
  }
}

Future<Logger> getLogger() async {
  Logger.root.level = Level.ALL;
  String loggingFilePath = './logs/dot_of_doom.txt';
  await setupLoggingPath(loggingFilePath);
  Logger.root.onRecord.listen((record) {
    final message =
        '${record.time} | ${record.level.name} | ${record.loggerName} | ${record.message}';
    print(message);
    final logFile = File(loggingFilePath);
    logFile.writeAsStringSync('$message\n', mode: FileMode.append);
  });
  final logger = Logger('Dot of Doom');

  return logger;
}
