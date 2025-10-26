import 'dart:convert';

import 'package:http/http.dart' as http;

class PcoApi {
  static final Uri baseUri = Uri.parse('https://api.planningcenteronline.com');

  String clientId;
  String clientSecret;

  PcoApi(this.clientId, this.clientSecret);

  dynamic get(String path) async {
    String basicAuth = 'Basic ${base64.encode(utf8.encode('$clientId:$clientSecret'))}';
    //service_type_api_response = @api.services.v2.service_types.get('where[name]': @config.service_type)
    var response = await http.get(
      baseUri.resolve(path),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Request failed with status: ${response.statusCode}.');
    }
  }
  //@api.services.v2.service_types.get()
  dynamic getService(String serviceTypeName) async {
    return await get('services/v2/service_types?name=$serviceTypeName');
  }
  //@api.services.v2.service_types[service_type_id].plans.get(order: '-created_at')
  dynamic getPlans(String serviceId) async {
    return await get('services/v2/service_types/$serviceId/plans?order=-created_at');
  }
	//@api.services.v2.service_types[service_type_id].plans[current_plan['id']].team_members.get(per_page: '50')
  dynamic getAllTeamMembersForPlan(String serviceTypeId, String currentPlanId) async {
    return await get('services/v2/service_types/$serviceTypeId/plans/$currentPlanId/team_members?per_page=50');
  }
	//@api.services.v2.teams.get('where[name]': team_name)
  dynamic getTeamsFromTeamName(String teamName) async {
    return await get('services/v2/teams?name=$teamName');
  }
	//@api.people.v2.people[player_id].phone_numbers.get()
  dynamic getPhoneNumbersFromPersonId(String personId) async {
    return await get('people/v2/people/$personId/phone_numbers');
  }
}