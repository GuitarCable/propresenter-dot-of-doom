dynamic getCurrentPlan(dynamic plans, dynamic config) {
  DateTime now = DateTime.now().toLocal();

  DateTime allowedStart = DateTime.now().subtract(Duration(hours: 12)).toLocal();
  DateTime allowedEnd = DateTime.now().add(Duration(days: 6)).toLocal();

  for (var plan in plans['data']) {
    if (plan['attributes']['service_time_count'] <= 0) {
      continue;
    }
    var planDateTemp = DateTime.parse(plan['attributes']['sort_date']);
    var planDate = DateTime.utc(planDateTemp.year, planDateTemp.month, planDateTemp.day, planDateTemp.hour + 6, planDateTemp.minute).toLocal();
    if (planDate.isAfter(allowedStart) &&
        planDate.isBefore(allowedEnd)) {
      var lastTimeTemp = DateTime.parse(plan['attributes']['last_time_at']);
      var lastTime = DateTime.utc(lastTimeTemp.year, lastTimeTemp.month, lastTimeTemp.day, lastTimeTemp.hour + 6, lastTimeTemp.minute).add(Duration(hours: 1, minutes: 15)).toLocal();
      if (now.isAfter(planDate) &&
          now.isBefore(lastTime)) {
        print("this should be in prod mode");
        config.debug = false;
        return plan;
      } else {
        config.debug = true;
        return plan;
      }
    }
  }
  throw Exception("No plan was found that matched current day");
}

dynamic isConfirmed(dynamic person) {
  if (person['attributes']['status'] == 'C' ||
      person['attributes']['status'] == 'Confirmed') {
    return true;
  } else {
    return false;
  }
}

dynamic getPlayer(dynamic team, String position) {
  for (var person in team['data']) {
    if (person['attributes']['team_position_name'].toString().toLowerCase() ==
            position.toLowerCase() &&
        isConfirmed(person)) {
      return person;
    }
  }
  throw Exception("No person was found for position: $position");
}

dynamic isInTeam(dynamic person, String teamId) {
  if (person['relationships']['team']['data']['id'] == teamId) {
    return true;
  } else {
    return false;
  }
}

String getTeamId(
  dynamic teamsApiResponse,
  String teamName,
  String serviceTypeId,
) {
  for (dynamic team in teamsApiResponse['data']) {
    if (team['relationships']['service_type']['data']['id'] == serviceTypeId &&
        team['attributes']['name'] == teamName) {
      return team['id'];
    }
  }
  throw Exception("Team not found for serviceTypeId $serviceTypeId");
}

String getPrimaryPhoneNumber(dynamic phoneNumberApiResponse) {
  for (dynamic data in phoneNumberApiResponse['data']) {
    if (data['attributes']['primary'] == true) {
      return data['attributes']['national'];
    }
  }
  throw Exception("No primary phone number found");
}
