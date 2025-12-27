import 'package:yaml/yaml.dart';

class Config {
  OAuth oAuth;
  String serviceType;
  String bandPosition;
  List<String> teamNames;
  bool sendAll;
  String backupNumber;
  List<String> failureLogEmails;
  String message;
  String messageType;
  String debug;

  bool suggestedDebug = true;

  Config(
    this.oAuth,
    this.serviceType,
    this.bandPosition,
    this.teamNames,
    this.sendAll,
    this.backupNumber,
    this.failureLogEmails,
    this.message,
    this.messageType,
    this.debug,
  );

  static Config from(dynamic yamlMap) {
    final YamlList? teamNameYamlList = yamlMap['teamNames'] as YamlList?;
    List<String> teamNameList = [];
    if (teamNameYamlList != null) {
      teamNameList = teamNameYamlList.nodes
          .map((node) => node.value.toString())
          .toList();
    }
    final YamlList? failureLogEmails = yamlMap['failureLogEmails'] as YamlList?;
    failureLogEmailList = [];
    if (failureLogEmails != null) {
      failureLogEmailList = failureLogEmails.nodes
          .map((node) => node.value.toString())
          .toList();
    }
    return Config(
      OAuth(yamlMap['oAuth']['clientId'], yamlMap['oAuth']['clientSecret']),
      yamlMap['serviceType'],
      yamlMap['bandPosition'],
      teamNameList,
      yamlMap['sendAll'],
      yamlMap['backupNumber'].toString(),
      failureLogEmails,
      yamlMap['message'],
      yamlMap['messageType'],
      yamlMap['debug'].toString(),
    );
  }
}

class OAuth {
  String clientId;
  String clientSecret;
  OAuth(this.clientId, this.clientSecret);
}
