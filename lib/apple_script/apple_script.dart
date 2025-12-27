import 'package:dart/apple_script/system_runner.dart/system_runner.dart';
import 'package:logging/logging.dart';

class AppleScript {
  Logger logger;
  bool debug;

  late SystemRunner systemRunner;

  AppleScript(this.logger, this.debug) {
    systemRunner = SystemRunner(logger);
  }

  Future<int> text(String phoneNumber, String message) async {
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
    if (debug) {
      logger.info('running text in debug mode');
      logger.info("\"sending text\" to $phoneNumber");
      return 0;
    } else {
      logger.info('running in prod mode');
      logger.info("sending text to $phoneNumber");
      return (await systemRunner.run(appleScriptCode));
    }
  }

  Future<int> email(String email, String message) async {
    String appleScriptCode =
        '''
		tell application "Mail"
    		set theMessage to make new outgoing message with properties {subject:"Dot of Doom Error", content:"${message}", visible:false}
    		tell theMessage
        		make new to recipient with properties {name:"${email.split('@')}", address:"$email"}
    		end tell
    		send theMessage -- This line sends the email automatically
		end tell
    ''';
    if (debug) {
      logger.info('running email in debug mode');
      logger.info("\"sending email\" to $phoneNumber");
      return 0;
    } else {
      logger.info('running in prod mode');
      logger.info("sending email to $phoneNumber");
      return (await systemRunner.run(appleScriptCode));
    }
  }
}
