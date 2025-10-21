class TextScript
    def initialize(logger, debug)
			@logger = logger
			@debug = debug
    end

    def send(phone_number, message)
        applescript_code = <<~HEREDOC

			on run argv
				tell application \"Messages\"
					set targetBuddy to \"#{phone_number}\"
					set textMessage to \"#{message}\" 
					set targetService to id of 1st account whose service type = iMessage
					set theBuddy to participant targetBuddy of account id targetService
					send textMessage to theBuddy
				end tell
				log \"Message sent\"
			end run
		HEREDOC

				@logger.info("Sending message to phone number: #{phone_number}")
				if @debug == false
						system("osascript -e '#{applescript_code}'")
				end
				@logger.info("Text successfully sent")
    end
end