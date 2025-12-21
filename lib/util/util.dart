dynamic getCurrentPlan(dynamic plans, dynamic config) {
  DateTime tempNow = DateTime.now().toLocal();
  DateTime now = DateTime.utc(tempNow.year, tempNow.month, tempNow.day, tempNow.hour, tempNow.minute);

  DateTime allowedStart = DateTime.now().subtract(Duration(hours: 12)).toLocal();
  DateTime allowedEnd = DateTime.now().add(Duration(days: 1)).toLocal();

  for (var plan in plans['data']) {
    if (plan['attributes']['service_time_count'] <= 0) {
      continue;
    }
    var planDate = DateTime.parse(plan['attributes']['sort_date']);
    if (planDate.isAfter(allowedStart) &&
        planDate.isBefore(allowedEnd)) {
      var lastTime = DateTime.parse(plan['attributes']['last_time_at']).add(Duration(hours: 1, minutes: 15));
      if (now.isAfter(planDate) &&
          now.isBefore(lastTime)) {
        config.suggestedDebug = false;
        return plan;
      } else {
        config.suggestedDebug = true;
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
