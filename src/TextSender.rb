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
	def initialize()
		@config = Config.new()
		LogFileGenerator.create_file_with_dirs(@config.logLocation)
		logFile = File.open(@config.logLocation, 'a')
		@logger = Logger.new(logFile, 'daily')
		if @config.debug != false
			@logger.level = Logger::DEBUG
			@logger.debug("Running in debug mode")
		else
			@logger.level = Logger::INFO
		end
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

	def run()
		@logger.info("Running TextSender")
		api = nil
		begin
			@logger.info("Initializing API")
			api = PCO::API.new(basic_auth_token: @config.client_id, basic_auth_secret: @config.client_secret)
			@logger.info("Successfully initialized API")
		rescue StandardError => err
			@logger.error("Failed to initialize API")
			@logger.error(err)
		end
		phone_number = nil
		begin
			plans = api.services.v2.service_types[@config.target_service_id].plans.get(order: '-created_at')

			current_plan = Util.get_current_plan(plans)

			team = api.services.v2.service_types[@config.target_service_id].plans[current_plan['id']].team_members.get(per_page: '50')

			target_player = Util.get_player(team, @config.position)

			keys_id = target_player['relationships']['person']['data']['id']
			phone_number_api_response = api.people.v2.people[keys_id].phone_numbers.get()
			phone_number = get_primary_phone_number(phone_number_api_response)
		rescue StandardError => err
			@logger.error("Failed to look up phone number. Defaulting to backup phone number.")
			@logger.error(err)
			phone_number = @config.backup_number
		end
		begin
			@logger.info("Sending text to #{phone_number}")
			text_script = TextScript.new()
			text_script.send(phone_number, @config.debug)
			@logger.info("Text successfully sent")
		rescue StandardError => err
			@logger.fatal("Failed to send message. Shutting down")
			@logger.fatal(err)
		end
		@logger.close
	end
end

text_sender = TextSender.new()
text_sender.run