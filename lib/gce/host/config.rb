require 'dotenv'
Dotenv.load
require 'inifile'

class GCE
  class Host
    class Config
      def self.configure(params)
        params.each do |key, val|
          send("#{key}=", val)
        end
      end

      def self.config_file
        @config_file ||= File.expand_path(ENV.fetch('GCE_HOST_CONFIG_FILE', '/etc/sysconfig/gce-host'))
      end

      def self.auth_method
        @auth_method ||= ENV['AUTH_METHOD'] || config.fetch('AUTH_METHOD', nil) || 'application_default'
      end

      def self.credentials_file
        # ref. https://developers.google.com/identity/protocols/application-default-credentials
        @credentials_file ||= File.expand_path(ENV['GOOGLE_APPLICATION_CREDENTIALS'] || config.fetch('GOOGLE_APPLICATION_CREDENTIALS', nil) || credentials_file_default)
      end

      def self.credentials_file_default
        @credentials_file_default ||= File.expand_path("~/.config/gcloud/application_default_credentials.json")
      end

      def self.credentials
        File.readable?(credentials_file) ? JSON.parse(File.read(credentials_file)) : {}
      end

      def self.config_default_file
        File.expand_path('~/.config/gcloud/configurations/config_default')
      end

      def self.config_default
        @config_default ||= File.readable?(config_default_file) ? IniFile.load(config_default_file).to_h : {}
      end

      def self.account_default
        (config_default['core'] || {})['account']
      end

      def self.project_default
        (config_default['core'] || {})['project']
      end

      def self.zone_default
        (config_default['compute'] || {})['zone']
      end

      def self.account
        @account ||= ENV['GOOGLE_ACCOUNT'] || config.fetch('GOOGLE_ACCOUNT', nil) || account_default
      end

      def self.project
        @project ||= ENV['GOOGLE_PROJECT'] || config.fetch('GOOGLE_PROJECT', nil) || credentials['project_id']
        @project ||= credentials['client_email'].chomp('.iam.gserviceaccount.com').split('@').last if credentials['client_email']
        @project ||= project_default
      end

      def self.log_level
        @log_level ||= ENV['LOG_LEVEL'] || config.fetch('LOG_LEVEL', 'info')
      end

      def self.retries
        @retries ||= ENV['RETRIES'] || config.fetch('RETRIES', 5)
      end

      def self.timeout_sec
        @timeout_sec ||= ENV['TIMEOUT_SEC'] || config.fetch('TIMEOUT_SEC', 300)
      end

      def self.open_timeout_sec
        @open_timeout_sec ||= ENV['OPEN_TIMEOUT_SEC'] || config.fetch('OPEN_TIMEOUT_SEC', 300)
      end

      def self.roles_key
        @roles_key ||= ENV['ROLES_KEY'] || config.fetch('ROLES_KEY', 'roles')
      end

      def self.optional_array_keys
        @optional_array_keys ||= (ENV['OPTIONAL_ARRAY_KEYS'] || config.fetch('OPTIONAL_ARRAY_KEYS', '')).split(',')
      end

      def self.optional_string_keys
        @optional_string_keys ||= (ENV['OPTIONAL_STRING_KEYS'] || config.fetch('OPTIONAL_STRING_KEYS', '')).split(',')
      end

      def self.role_value_delimiter
        @role_value_delimiter ||= ENV['ROLE_VALUE_DELIMITER'] || config.fetch('ROLE_VALUE_DELIMITER', ':')
      end

      def self.array_value_delimiter
        @array_value_delimiter ||= ENV['ARRAY_VALUE_DELIMITER'] || config.fetch('ARRAY_VALUE_DELIMITER', ',')
      end

      # this makes configurable to change status to state to make compatible with AWS
      # usually, users do not need to care of this
      def self.status
        @status ||= ENV['STATUS'] || config.fetch('STATUS', 'status')
      end

      # private

      def self.optional_array_options
        @optional_array_options ||= Hash[optional_array_keys.map {|key|
          [StringUtil.singularize(StringUtil.underscore(key)), key]
        }]
      end

      def self.optional_string_options
        @optional_string_options ||= Hash[optional_string_keys.map {|key|
          [StringUtil.underscore(key), key]
        }]
      end

      def self.optional_options
        @optional_options ||= optional_array_options.merge(optional_string_options)
      end

      def self.config
        return @config if @config
        @config = {}
        if File.exist?(config_file)
          File.readlines(config_file).each do |line|
            next if line.start_with?('#')
            key, val = line.chomp.split('=', 2)
            @config[key] = val
          end
        end
        @config
      end
    end
  end
end
