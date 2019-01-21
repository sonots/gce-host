require 'json'

class GCE
  class Host
    # Represents each host
    class HostData
      attr_reader :instance

      # :hostname, # hostname
      # :roles,    # roles.split(',') such as web:app1,db:app1
      # :instance, # Aws::GCE::Types::Instance itself
      #
      # and OPTIONAL_ARRAY_KEYS, OPTIONAL_STRING_KEYS
      def initialize(instance)
        @instance = instance
      end

      def hostname
        instance.name
      end

      def roles
        return @roles if @roles
        roles = find_array_key(Config.roles_key)
        @roles = roles.map {|role| GCE::Host::RoleData.build(role) }
      end

      Config.optional_string_keys.each do |key|
        field = StringUtil.underscore(key)
        define_method(field) do
          instance_variable_get("@#{field}") || instance_variable_set("@#{field}", find_string_key(key))
        end
      end

      Config.optional_array_keys.each do |key|
        field = StringUtil.underscore(key)
        define_method(field) do
          instance_variable_get("@#{field}") || instance_variable_set("@#{field}", find_array_key(key))
        end
      end

      define_method(Config.status) do
        instance.status
      end

      def instance_id
        instance.id
      end

      def zone
        instance.zone.split('/').last
      end

      def machine_type
        instance.machine_type.split('/').last
      end

      def private_ip_address
        instance.network_interfaces.first.network_ip
      end

      def private_ip_addresses
        instance.network_interfaces.map(&:network_ip)
      end

      def public_ip_address
        access_configs = instance.network_interfaces.first.access_configs
        access_configs ? access_configs.first.nat_ip : nil
      end

      def public_ip_addresses
        instance.network_interfaces.map {|i|
          i.access_configs ? i.access_configs.map(&:nat_ip) : nil
        }.flatten(1).compact
      end

      def creation_timestamp
        instance.creation_timestamp
      end

      # compatibility with dino-host
      def ip
        private_ip_address
      end

      # compatibility with dino-host
      def start_date
        creation_timestamp
      end

      # compatibility with dino-host
      def usages
        roles
      end

      # NOTE: this is stopped status in the case of GCE unlike EC2
      def terminated?
        instance.status == "TERMINATED"
      end

      def stopping?
        instance.status == "STOPPING"
      end

      def running?
        instance.status == "RUNNING"
      end

      def staging?
        instance.status == "STAGING"
      end

      def provisioning?
        instance.status == "PROVISIONING"
      end

      # match with condition or not
      #
      # @param [Hash] condition search parameters
      def match?(condition)
        return false unless role_match?(condition)
        return false unless status_match?(condition)
        return false unless instance_match?(condition)
        true
      end

      def to_hash
        params = {
          "hostname" => hostname,
          "roles" => roles,
        }
        Config.optional_string_keys.each do |key|
          field = StringUtil.underscore(key)
          params[field] = send(field)
        end
        Config.optional_array_keys.each do |key|
          field = StringUtil.underscore(key)
          params[field] = send(field)
        end
        params.merge!(
          "zone" => zone,
          "machine_type" => machine_type,
          "private_ip_address" => private_ip_address,
          "public_ip_address" => public_ip_address,
          "creation_timestamp" => creation_timestamp,
          Config.status => send(Config.status),
        )
      end

      def info
        if self.class.display_short_info?
          info = "#{hostname}:#{status}"
          info << "(#{roles.join(',')})" unless roles.empty?
          info << "[#{tags.join(',')}]" unless tags.empty?
          info << "{#{service}}" unless service.empty?
          info
        else
          to_hash.to_s
        end
      end

      def inspect
        sprintf "#<GCE::Host::HostData %s>", info
      end

      private

      def find_string_key(key)
        item = instance.metadata.items.find {|item| item.key == key } if instance.metadata.items
        item ? item.value : ''
      end

      def find_array_key(key)
        item = instance.metadata.items.find {|item| item.key == key } if instance.metadata.items
        item ? item.value.split(Config.array_value_delimiter) : []
      end

      def role_match?(condition)
        # usage is an alias of role
        if role = (condition[:role] || condition[:usage])
          role.any? do |r|
            parts = r.split(Config.role_value_delimiter, Config.role_max_depth)
            next true if parts.compact.empty? # no role conditions
            roles.find {|role| role.match?(*parts) }
          end
        else
          parts = 1.upto(Config.role_max_depth).map do |i|
            condition["role#{i}".to_sym] || condition["usage#{i}".to_sym]
          end
          return true if parts.compact.empty? # no role conditions
          roles.find {|role| role.match?(*parts) }
        end
      end

      def status_match?(condition)
        if values = condition[Config.status.to_sym]
          return false unless values.map(&:downcase).include?(send(Config.status).downcase)
        end
        true
      end

      def instance_match?(condition)
        excepts = [:role, :usage, Config.status.to_sym]
        1.upto(Config.role_max_depth).each {|i| excepts << "role#{i}".to_sym }
        1.upto(Config.role_max_depth).each {|i| excepts << "usage#{i}".to_sym }
        condition = HashUtil.except(condition, *excepts)
        condition.each do |key, values|
          v = instance_variable_recursive_get(key)
          if v.is_a?(Array)
            return false unless v.find {|_| values.include?(_.to_s) }
          else
            return false unless values.include?(v.to_s)
          end
        end
        true
      end

      # "instance.instance_id" => self.instance.instance_id
      def instance_variable_recursive_get(key)
        v = self
        key.to_s.split('.').each {|k| v = v.send(k) }
        v
      end

      # compatibility with dono-host
      #
      # If service,status,tags keys are defined
      #
      #     OPTIONAL_STRING_KEYS=service,status
      #     OPTIONAL_ARRAY_KEYS=tags
      #
      # show in short format, otherwise, same with to_hash.to_s
      def self.display_short_info?
        return @display_short_info unless @display_short_info.nil?
        @display_short_info = method_defined?(:service) and method_defined?(:status) and method_defined?(:tags)
      end
    end
  end
end
