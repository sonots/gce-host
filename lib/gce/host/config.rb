require 'dotenv'
Dotenv.load

class GCE
  class Host
    class Config
      class << self
        attr_writer :config_file,
          :auth_method
          :json_keyfile,
          :gce_zone,
          :log_level,
          :hostname_tag,
          :roles_tag,
          :optional_array_tags,
          :optional_string_tags
      end

      def self.configure(params)
        params.each do |key, val|
          send("#{key}=", val)
        end
      end

      def self.config_file
        @config_file ||= ENV.fetch('GCE_HOST_CONFIG_FILE', '/etc/sysconfig/gce-host')
      end

      def self.auth_method
        @auth_method ||= ENV['AUTH_METHOD'] || config.fetch('AUTH_METHOD') || 'compute_engine'
      end

      def self.json_keyfile
        @json_keyfile ||= ENV['JSON_KEYFILE'] || config.fetch('JSON_KEYFILE', nil)
      end

      def self.gce_zone
        @gce_zone ||= ENV['GCE_ZONE'] || config.fetch('GCE_ZONE')
      end

      def self.log_level
        @log_level ||= ENV['LOG_LEVEL'] || config.fetch('LOG_LEVEL', 'info')
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
        File.readlines(config_file).each do |line|
          next if line.start_with?('#')
          key, val = line.chomp.split('=', 2)
          @config[key] = val
        end
        @config
      end
    end
  end
end
