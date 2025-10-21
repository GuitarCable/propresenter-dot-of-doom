#!/usr/bin/env ruby

require 'date'
require 'logger'
require 'pco_api'
require 'tmpdir'

require_relative 'appleScript/TextScript.rb'
require_relative 'config/Config.rb'
require_relative 'util/LogFileGenerator.rb'
require_relative 'util/Util.rb'

class TextSender
	def initialize_api()
		begin
			@logger.info("Initializing API")
			api = PCO::API.new(basic_auth_token: @config.client_id, basic_auth_secret: @config.client_secret)
			@logger.info("Successfully initialized API")
			return api
		rescue StandardError => err
			@logger.error(err)
			@logger.error("Failed to initialize API")
			return nil
		end
	end

	def initialize()
		@config = Config.new()
		log_location = "logs/text_sender.log"
		LogFileGenerator.create_file_with_dirs(log_location)
		logFile = File.open(log_location, 'a')
		@logger = Logger.new(logFile, 'daily')
		if @config.debug != false
			@logger.level = Logger::DEBUG
			@logger.debug("Running in debug mode")
		else
			@logger.level = Logger::INFO
		end
		@api = initialize_api()

		@success = true
		
		@logger.info("TextSender initialized.")
	end

	def get_primary_phone_number(phone_number_api_response) 
		for data in phone_number_api_response['data']
			if data['attributes']['primary'] == true
				return data['attributes']['national']
			end
		end
		raise("No primary phone number found")
	end

	def get_phone_numbers()
		begin
			service_type_api_response = @api.services.v2.service_types.get('where[name]': @config.service_type)
			service_type_id = service_type_api_response['data'][0]['id']
			
			plans = @api.services.v2.service_types[service_type_id].plans.get(order: '-created_at')

			current_plan = Util.get_current_plan(plans)

			team = @api.services.v2.service_types[service_type_id].plans[current_plan['id']].team_members.get(per_page: '50')

			players = []

			if @config.send_all == true
				for team_name in @config.team_names
					teams_api_response = @api.services.v2.teams.get('where[name]': team_name)
					team_id = nil
					for temp_team in teams_api_response['data']
						if temp_team['relationships']['service_type']['data']['id'] == service_type_id
							team_id = temp_team['id']
							break
						end
					end
					for member in team['data']
						if Util.is_confirmed(member) && Util.is_in_team(member, team_id)
							players.push(member)
						end
					end
				end
				players = players.uniq
			else
				players.push(Util.get_player(team, @config.band_position))
			end

			phone_numbers = []
			for player in players
				player_id = player['relationships']['person']['data']['id']
				phone_number_api_response = @api.people.v2.people[player_id].phone_numbers.get()
				phone_numbers.push(get_primary_phone_number(phone_number_api_response))
			end
			return phone_numbers
		rescue StandardError => err
			@logger.error("\n#{err}")
			@logger.error("Failed to look up phone number. Check the logs for reason of failure.")
			@success = false
			return [@config.backup_number]
		end
	end

	def run()
		@logger.info("Running TextSender")
		
		phone_numbers = get_phone_numbers()
		message = nil
		if @success
			message = @config.message
		else
			message = "Something failed when looking up phone numbers. Sending this to the backup number."
		end
		for phone_number in phone_numbers
			begin
				text_script = TextScript.new(@logger, @config.debug)
				text_script.send(phone_number, message)
			rescue StandardError => err
				@logger.error("\n#{err}")
				@logger.error("Failed to send message to #{phone_number}. Check to see if this user has iMessage")
			end
		end		
		@logger.close
	end
end

text_sender = TextSender.new()
text_sender.run