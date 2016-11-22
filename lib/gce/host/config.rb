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
        @config_file ||= ENV.fetch('GCE_HOST_CONFIG_FILE', '/etc/sysconfig/gce-host')
      end

      def self.project_id
        return @project_id if @project_id
        @project_id ||= ENV['PROJECT_ID'] || config.fetch('PROJECT_ID', nil)
        if @project_id.nil? and json_keyfile and File.readable?(json_keyfile)
          @project_id ||= (JSON.parse(File.read(json_keyfile)) || {})['project_id']
        end
        @project_id
      end

      def self.auth_method
        @auth_method ||= ENV['AUTH_METHOD'] || config.fetch('AUTH_METHOD', 'application_default')
      end

      def self.json_keyfile
        @json_keyfile ||= ENV['JSON_KEYFILE'] || config.fetch('JSON_KEYFILE', nil)
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

      def self.roles_label
        @roles_label ||= ENV['ROLES_LABEL'] || config.fetch('ROLES_LABEL', 'roles')
      end

      def self.optional_array_labels
        @optional_array_labels ||= (ENV['OPTIONAL_ARRAY_LABELS'] || config.fetch('OPTIONAL_ARRAY_LABELS', '')).split(',')
      end

      def self.optional_string_labels
        @optional_string_labels ||= (ENV['OPTIONAL_STRING_LABELS'] || config.fetch('OPTIONAL_STRING_LABELS', '')).split(',')
      end

      def self.role_label_delimiter
        @role_label_delimiter ||= ENV['ROLE_LABEL_DELIMITER'] || config.fetch('ROLE_LABEL_DELIMITER', ':')
      end

      def self.array_label_delimiter
        @array_label_delimiter ||= ENV['ARRAY_LABEL_DELIMITER'] || config.fetch('ARRAY_LABEL_DELIMITER', ',')
      end

      # I wanted to make it be configurable to change status to state to make compatible with AWS
      # usually, users do not need to care of this
      def self.status
        @status ||= ENV['STATUS'] || config.fetch('STATUS', 'status')
      end

      # private

      def self.optional_array_options
        @optional_array_options ||= Hash[optional_array_labels.map {|label|
          [StringUtil.singularize(StringUtil.underscore(label)), label]
        }]
      end

      def self.optional_string_options
        @optional_string_options ||= Hash[optional_string_labels.map {|label|
          [StringUtil.underscore(label), label]
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
