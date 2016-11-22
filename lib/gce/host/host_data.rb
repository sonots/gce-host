require 'json'

class GCE
  class Host
    # Represents each host
    class HostData
      attr_reader :instance

      # :hostname, # hostname
      # :roles,    # labels.role.split(',') such as web:app1,db:app1
      # :instance, # Aws::GCE::Types::Instance itself
      #
      # and OPTIONAL_ARRAY_LABELS, OPTIONAL_STRING_LABELS
      def initialize(instance)
        @instance = instance
      end

      def roles
        return @roles if @roles
        roles = find_array_label(Config.roles_label)
        @roles = roles.map {|role| GCE::Host::RoleData.initialize(role) }
      end

      Config.optional_string_labels.each do |label|
        field = StringUtil.underscore(label)
        define_method(field) do
          instance_variable_get("@#{field}") || instance_variable_set("@#{field}", find_string_label(label))
        end
      end

      Config.optional_array_labels.each do |label|
        field = StringUtil.underscore(label)
        define_method(field) do
          instance_variable_get("@#{field}") || instance_variable_set("@#{field}", find_array_label(label))
        end
      end

      private def find_string_label(key)
        (instance.labels || {})[key] || ''
      end

      private def find_array_label(key)
        v = (instance.labels || {})[key]
        v ? v.split(Config.array_label_delimiter) : []
      end

      def hostname
        instance.name
      end

      def instance_id
        instance.id
      end

      define_method(Config.status) do
        instance.status
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
        instance.network_interfaces.first.access_configs.first.nat_ip
      end

      def public_ip_addresses
        instance.network_interfaces.map {|i| i.access_configs.map(&:nat_ip) }.flatten(1)
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
        return false if !condition[Config.status.to_sym] and (terminated? or stopping?)
        return false unless role_match?(condition)
        return false unless status_match?(condition)
        return false unless instance_match?(condition)
        true
      end

      private def role_match?(condition)
        # usage is an alias of role
        if role = (condition[:role] || condition[:usage])
          role1, role2, role3 = role.first.split(':')
        else
          role1 = (condition[:role1] || condition[:usage1] || []).first
          role2 = (condition[:role2] || condition[:usage2] || []).first
          role3 = (condition[:role3] || condition[:usage3] || []).first
        end
        if role1
          return false unless roles.find {|role| role.match?(role1, role2, role3) }
        end
        true
      end

      private def status_match?(condition)
        if values = condition[Config.status.to_sym]
          return false unless values.map(&:downcase).include?(send(Config.status).downcase)
        end
        true
      end

      private def instance_match?(condition)
        condition = HashUtil.except(condition, :role, :role1, :role2, :role3, :usage, :usage1, :usage2, :usage3, Config.status.to_sym)
        condition.each do |key, values|
          v = instance_variable_recursive_get(key)
          if v.is_a?(Array)
            return false unless v.find {|_| values.include?(_) }
          else
            return false unless values.include?(v)
          end
        end
        true
      end

      # "instance.instance_id" => self.instance.instance_id
      private def instance_variable_recursive_get(key)
        v = self
        key.to_s.split('.').each {|k| v = v.send(k) }
        v
      end

      def to_hash
        params = {
          "hostname" => hostname,
          "roles" => roles,
        }
        Config.optional_string_labels.each do |label|
          field = StringUtil.underscore(label)
          params[field] = send(field)
        end
        Config.optional_array_labels.each do |label|
          field = StringUtil.underscore(label)
          params[field] = send(field)
        end
        params.merge!(
          "instance_id" => instance_id,
          "zone" => zone,
          "machine_type" => machine_type,
          "private_ip_address" => private_ip_address,
          "public_ip_address" => public_ip_address,
          "creation_timestamp" => creation_timestamp,
          Config.status => send(Config.status),
        )
      end

      # compatibility with dono-host
      #
      # If Service,Status,Tags labels are defined
      #
      #     OPTIONAL_STRING_LABELS=Service,Status
      #     OPTIONAL_ARRAY_LABELS=Tags
      #
      # show in short format, otherwise, same with to_hash.to_s
      def self.display_short_info?
        return @display_short_info unless @display_short_info.nil?
        @display_short_info = method_defined?(:service) and method_defined?(:status) and method_defined?(:tags)
      end

      def info
        if self.class.display_short_info?
          info = "#{hostname}:#{status}"
          info << "(#{roles.join(' ')})" unless roles.empty?
          info << "[#{tags.join(' ')}]" unless tags.empty?
          info << "{#{service}}" unless service.empty?
          info
        else
          to_hash.to_s
        end
      end

      def inspect
        sprintf "#<GCE::Host::HostData %s>", info
      end
    end
  end
end
