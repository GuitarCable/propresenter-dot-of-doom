require 'yaml'

class Config
    attr_reader :target_service_id
    attr_reader :position
    attr_reader :backup_number
    attr_reader :client_id
    attr_reader :client_secret
    attr_reader :debug
    attr_reader :logLocation


    def get_value_from_key(key, key_value_pairs)
        for key_value in key_value_pairs
  
            if key.casecmp(key_value[0]) == 0
              return key_value[1]
            end
        end
        return ""
    end

    def initialize()
        @config = YAML.load_file('./config.yml')

        @target_service_id = get_value_from_key(@config['serviceType'], @config['allServiceTypes'])
        @position          = get_value_from_key(@config['bandPosition'], @config['allBandPositions'])
        @backup_number     = @config['backupNumber']
        @client_id         = @config['oAuth']['clientId']
        @client_secret     = @config['oAuth']['clientSecret']
        @debug             = @config['debug']
        @logLocation       = @config['logLocation']
    end
end