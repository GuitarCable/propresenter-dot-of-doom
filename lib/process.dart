import 'dart:io';
import 'package:dart/apple_script/apple_script.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:dart/config/config.dart';
import 'package:dart/pco_api/pco_api.dart';
import 'package:dart/util/util.dart' as util;

class Process {
  LogWrapper logWrapper;
  late Logger logger
  late Config config;
  late PcoApi pcoApi;

  Process(String configLocation, this.logWrapper) {
    logWrapper.log('initializing config', Level.info);
    logger = logWrapper.logger;
    String configFileContents = File('config.yml').readAsStringSync();
    config = Config.from(yaml.loadYaml(configFileContents));

    pcoApi = PcoApi(config.oAuth.clientId, config.oAuth.clientSecret);
  }

  dynamic getServiceTypeId() async {
    //service_type_api_response = @api.services.v2.service_types.get('where[name]': @config.service_type)
    var serviceTypeApiResponse = await pcoApi.getServiceType(
      config.serviceType,
    );
    //service_type_id = service_type_api_response['data'][0]['id']
    String serviceTypeId = serviceTypeApiResponse['data'][0]['id'];
    return serviceTypeId;
  }

  dynamic getCurrentPlan(String serviceTypeId) async {
    var plans = await pcoApi.getPlans(serviceTypeId);

    var currentPlan = util.getCurrentPlan(plans, config);
    return currentPlan;
  }

  dynamic getPlayers(String serviceTypeId, currentPlanId) async {
    // team = @api.services.v2.service_types[service_type_id].plans[current_plan['id']].team_members.get(per_page: '50')
    var teamApiResponse = await pcoApi.getAllTeamMembersForPlan(
      serviceTypeId,
      currentPlanId,
    );
    List<dynamic> players = [];
    Map<String, dynamic> tempPlayers = {};

    if (config.sendAll == true) {
      for (String teamName in config.teamNames) {
        logWrapper.log("current team is: $teamName", Level.info);
        dynamic teamsApiResponse = await pcoApi.getTeamsFromTeamName(teamName);
        String teamId = util.getTeamId(
          teamsApiResponse,
          teamName,
          serviceTypeId,
        );
        // logger.info("Current teamId is $teamId");

        for (dynamic member in teamApiResponse['data']) {
          if (util.isConfirmed(member) && util.isInTeam(member, teamId)) {
            tempPlayers[member['attributes']['name']] = member;
          }
        }
      }
      players.addAll(tempPlayers.values);
    } else {
      players.add(util.getPlayer(teamApiResponse, config.bandPosition));
    }
    return players;
  }

  Future<List<String>> getPhoneNumbers(dynamic players) async {
    List<String> phoneNumbers = [];
    for (dynamic player in players) {
      String playerId = player['relationships']['person']['data']['id'];
      dynamic phoneNumberApiResponse = await pcoApi.getPhoneNumbersFromPersonId(
        playerId,
      );
      phoneNumbers.add(util.getPrimaryPhoneNumber(phoneNumberApiResponse));
    }
    return phoneNumbers;
  }

  void sendMessages(List<String> phoneNumbers) async {
    AppleScript appleScript = AppleScript(logWrapper.logger, determineDebug());

    for (String phoneNumber in phoneNumbers) {
      try {
        await appleScript.text(phoneNumber, config.message);
      } catch (e) {
        logger.severe('failed to text $phoneNumber');
        logger.severe(e);
      }
    }
  }

  void sendFailureText() async {
    AppleScript appleScript = AppleScript(logWrapper.logger, true);

    try {
      await appleScript.text(config.backupPhoneNumber, "Process failed. Check the logs");
    } catch (e) {
      logger.severe('failed to text ${config.backupPhoneNumber}');
      logger.severe(e);
    }
  }

  void sendFailureEmails() async {
    AppleScript appleScript = AppleScript(logWrapper.logger, true);

    for (String email in config.failureLogEmails) {
      try {
        await appleScript.email(email, logWrapper.getLogDump());
      } catch (e) {
        logger.severe('failed to email $email');
        logger.severe(e);
      }
    }
  }

  bool determineDebug() {
    switch (config.debug.toLowerCase()) {
      case "true":
        return true;
      case "false":
        return false;
      case "auto":
        logger.info("using suggested debug setting");
        return config.suggestedDebug;
      default:
        return true;
    }
  }
}
