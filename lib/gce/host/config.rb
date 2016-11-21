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

      def self.max_filter_metadata_index
        @max_filter_metdata_index ||= ENV['MAX_FILTER_METADATA_INDEX'] || config.fetch('MAX_FILTER_METADATA_INDEX',10)
      end

      def self.hostname_tag
        @hostname_tag ||= ENV['HOSTNAME_TAG'] || config.fetch('HOSTNAME_TAG', 'Name')
      end

      def self.roles_tag
        @roles_tag ||= ENV['ROLES_TAG'] || config.fetch('ROLES_TAG', 'Roles')
      end

      def self.optional_array_tags
        @optional_array_tags ||= (ENV['OPTIONAL_ARRAY_TAGS'] || config.fetch('OPTIONAL_ARRAY_TAGS', '')).split(',')
      end

      def self.optional_string_tags
        @optional_string_tags ||= (ENV['OPTIONAL_STRING_TAGS'] || config.fetch('OPTIONAL_STRING_TAGS', '')).split(',')
      end

      def self.role_tag_delimiter
        @role_tag_delimiter ||= ENV['ROLE_TAG_DELIMITER'] || config.fetch('ROLE_TAG_DELIMITER', ':')
      end

      def self.array_tag_delimiter
        @array_tag_delimiter ||= ENV['ARRAY_TAG_DELIMITER'] || config.fetch('ARRAY_TAG_DELIMITER', ',')
      end

      # private

      def self.optional_array_options
        @optional_array_options ||= Hash[optional_array_tags.map {|tag|
          [StringUtil.singularize(StringUtil.underscore(tag)), tag]
        }]
      end

      def self.optional_string_options
        @optional_string_options ||= Hash[optional_string_tags.map {|tag|
          [StringUtil.underscore(tag), tag]
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
