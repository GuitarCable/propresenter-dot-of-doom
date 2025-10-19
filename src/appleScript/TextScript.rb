class TextScript
    def initialize()
    end

    def send(phone_number, debug)
        applescript_code = <<~HEREDOC

			on run argv
				tell application \"Messages\"
					set targetBuddy to \"#{phone_number}\"
					set textMessage to \"This is Caleb. Sending a text from a ProPresenter macro.\" 
					set targetService to id of 1st account whose service type = iMessage
					set theBuddy to participant targetBuddy of account id targetService
					send textMessage to theBuddy
				end tell
				log \"Message sent\"
			end run
		HEREDOC

		if debug != false
			puts "Running in debug mode."
			puts applescript_code
		else
			system("osascript -e '#{applescript_code}'")
		end
    end
end