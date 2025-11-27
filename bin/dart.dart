import 'dart:io';
import 'package:yaml/yaml.dart' as yaml;
import 'package:dart/apple_script/apple_script.dart';
import 'package:dart/util/util.dart' as util;
import 'package:dart/pco_api/pco_api.dart';
import 'package:dart/logger/logger.dart' as log;
import 'package:logging/logging.dart';

void main(List<String> arguments) async {
  Logger logger = await log.getLogger();
  logger.info('initializing config');
  String configFileContents = File('config.yml').readAsStringSync();
  var config = Map.from(yaml.loadYaml(configFileContents));

  PcoApi pcoApi = PcoApi(
    config['oAuth']['clientId'],
    config['oAuth']['clientSecret'],
  );

  String serviceType;
  logger.info(arguments);
  if (arguments.isNotEmpty) {
    serviceType = arguments.first;
  } else {
    serviceType = config['serviceType'];
  }
  logger.info(serviceType);
  //service_type_api_response = @api.services.v2.service_types.get('where[name]': @config.service_type)
  var serviceTypeApiResponse = await pcoApi.getServiceType(serviceType);
  //service_type_id = service_type_api_response['data'][0]['id']
  String serviceTypeId = serviceTypeApiResponse['data'][0]['id'];

  var plans = await pcoApi.getPlans(serviceTypeId);

  var currentPlan = util.getCurrentPlan(plans, config);

  // team = @api.services.v2.service_types[service_type_id].plans[current_plan['id']].team_members.get(per_page: '50')
  var teamApiResponse = await pcoApi.getAllTeamMembersForPlan(
    serviceTypeId,
    currentPlan['id'],
  );
  List<dynamic> players = [];
  Map<String, dynamic> tempPlayers = {};

  if (config['sendAll'] == true) {
    for (String teamName in config['teamNames']) {
      logger.info("current team is: $teamName");
      dynamic teamsApiResponse = await pcoApi.getTeamsFromTeamName(teamName);
      String teamId = util.getTeamId(teamsApiResponse, teamName, serviceTypeId);
      logger.info("Current teamId is $teamId");

      for (dynamic member in teamApiResponse['data']) {
        if (util.isConfirmed(member) && util.isInTeam(member, teamId)) {
          tempPlayers[member['attributes']['name']] = member;
        }
      }
    }
    players.addAll(tempPlayers.values);
  } else {
    players.add(util.getPlayer(teamApiResponse, config['bandPosition']));
  }

  List<String> phoneNumbers = [];
  for (dynamic player in players) {
    String playerId = player['relationships']['person']['data']['id'];
    dynamic phoneNumberApiResponse = await pcoApi.getPhoneNumbersFromPersonId(
      playerId,
    );
    phoneNumbers.add(util.getPrimaryPhoneNumber(phoneNumberApiResponse));
  }

  AppleScript appleScript = AppleScript(logger, config['debug']);

  for (String phoneNumber in phoneNumbers) {
    try {
      appleScript.text(phoneNumber, config['message']);
    } catch (e) {
      logger.severe('failed to text $phoneNumber');
      logger.severe(e);
    }
  }
}
