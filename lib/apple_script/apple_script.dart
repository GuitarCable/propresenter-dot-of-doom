import 'dart:io';

import 'package:logging/logging.dart';

class AppleScript {
  Logger logger;
  bool debug;

  AppleScript(this.logger, this.debug);

  void text(String phoneNumber, String message) async {
    String appleScriptCode =
        '''
      on run argv
	      tell application "Messages"
		      set targetBuddy to "$phoneNumber"
	        set textMessage to "$message" 
		      set targetService to id of 1st account whose service type = iMessage
	        set theBuddy to participant targetBuddy of account id targetService
		      send textMessage to theBuddy
	      end tell
	      log "Message sent"
      end run
    ''';
    logger.info("sending text to $phoneNumber");
    if (debug) {
      logger.info('running text in debug mode');
    } else {
      logger.info('running in prod mode');
      // final result = await Process.run('osascript', ['-e', appleScriptCode]);
      // if (result.exitCode == 0) {
      //   logger.info('AppleScript executed successfully:');
      //   logger.info(result.stdout);
      // } else {
      //   logger.severe('Error executing AppleScript:');
      //   logger.severe(result.stderr);
      // }
    }
  }
}
