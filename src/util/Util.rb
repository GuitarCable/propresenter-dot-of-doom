module Util
    def self.get_player(team, position)
	    for person in team['data'] do
		    if person['attributes']['team_position_name'].casecmp(position) == 0 && (person['attributes']['status'] == 'C' || person['attributes']['status'] == 'Confirmed')
			    return person
		    end
	    end
    end

    def self.get_current_plan(plans)
        next_sunday = Date.today + ((7 - Date.today.wday) % 7)
        
        for plan in plans['data'] do
            if Date.parse(plan['attributes']['sort_date']).to_date == next_sunday.to_date
                return plan
            end
        end
    end
end