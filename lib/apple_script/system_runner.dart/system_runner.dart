import 'dart:io';

import 'package:logging/logging.dart';

class SystemRunner {
  Logger logger;

  SystemRunner(this.logger);

  Future<int> run(String script) async {
    ProcessResult result = await Process.run('osascript', ['-e', script]);
    if (result.exitCode == 0) {
      logger.info('script executed successfully:');
      logger.info(result.stdout);
    } else {
      logger.severe('Error executing script:');
      logger.severe(result.stderr);
    }
    return result.exitCode;
  }
}