import 'package:args/args.dart';
import 'package:dart/process.dart';
import 'package:dart/logger/logger.dart';
import 'package:logging/logging.dart';

const String configLocation = 'config.yml';

void main(List<String> arguments) async {
  var parser = ArgParser();
  parser.addOption('serviceType', help: 'Service type to run app for');
  var results = parser.parse(arguments);

  LogWrapper logWrapper = await LogWrapper();

  Process process = Process(configLocation, logWrapper);
  
  try {
    if (results['serviceType'] != null) {
      logger.info(
        "Running with overridden service type: ${results['serviceType']}",
      );
      process.config.serviceType = results['serviceType'];
    }

    String serviceTypeId = await process.getServiceTypeId();
    var currentPlan = await process.getCurrentPlan(serviceTypeId);
    var players = await process.getPlayers(serviceTypeId, currentPlan['id']);
    List<String> phoneNumbers = await process.getPhoneNumbers(players);
    process.sendMessages(phoneNumbers);
  } catch (e) {
    await process.sendFailureText();
    await process.sendFailureEmails();
  }
}
