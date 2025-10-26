dynamic getCurrentPlan(dynamic plans) {
  DateTime now = DateTime.now();
  final nextSunday = now.add(Duration(days: (7 - now.weekday) % 7));
        
  for (var plan in plans['data']) {
    if (DateTime.parse(plan['attributes']['sort_date']).day == nextSunday.day) {
      return plan;
    }
  }
  throw Exception("No plan was found that matched current day");
}

dynamic isConfirmed(dynamic person) {
  if (person['attributes']['status'] == 'C' || person['attributes']['status'] == 'Confirmed') {
		return true;
  } else {
    return false;
  }
}

dynamic getPlayer(dynamic team, String position) {
	for (var person in team['data']) {
		if (person['attributes']['team_position_name'].casecmp(position) == 0 && isConfirmed(person)) {
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

String getTeamId(dynamic teamsApiResponse, String serviceTypeId) {
  for (dynamic team in teamsApiResponse['data']) {
		if (team['relationships']['service_type']['data']['id'] == serviceTypeId) {
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