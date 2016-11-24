require 'dotenv'
Dotenv.load

class GCE
  class Host
    class Config
      def self.configure(params)
        params.each do |key, val|
          send("#{key}=", val)
        end
      end

      def self.config_file
        @config_file ||= ENV.fetch('GCE_HOST_CONFIG_FILE', '/etc/sysconfig/gce-host').gsub('$HOME', Dir.home)
      end

      def self.auth_method
        @auth_method ||= ENV['AUTH_METHOD'] || config.fetch('AUTH_METHOD', 'application_default')
      end

      def self.credential_file
        @credential_file ||= (ENV['GOOGLE_CREDENTIAL_FILE'] || config.fetch('GOOGLE_CREDENTIAL_FILE')).gsub('$HOME', Dir.home)
      end

      def self.project
        return @project if @project
        # ref. terraform https://www.terraform.io/docs/providers/google/
        @project ||= ENV['GOOGLE_PROJECT'] || config.fetch('GOOGLE_PROJECT', nil)
        if @project.nil? and credential_file and File.readable?(credential_file)
          @project ||= (JSON.parse(File.read(credential_file)) || {})['project_id']
        end
        @project
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
