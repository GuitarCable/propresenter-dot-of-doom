require 'yaml'

class Config
    attr_reader :service_type
    attr_reader :band_position
    attr_reader :send_all
    attr_reader :backup_number
    attr_reader :client_id
    attr_reader :client_secret
    attr_reader :debug
    attr_reader :log_location
    attr_reader :message
    attr_reader :team_names

    def initialize()
        @config = YAML.load_file('./config.yml')

        @client_id         = @config['oAuth']['clientId']
        @client_secret     = @config['oAuth']['clientSecret']
        @service_type      = @config['serviceType']
        @team_names        = @config['teamNames']
        @band_position     = @config['bandPosition']
        @send_all          = @config['sendAll']
        @backup_number     = @config['backupNumber']
        @message           = @config['message']
        @debug             = @config['debug']
    end
end