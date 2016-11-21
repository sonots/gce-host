require 'forwardable'
require 'hashie/mash'
require 'json'

class GCE
  class Host
    # Represents each host
    class HostData < Hashie::Mash
      # :hostname, # tag:Name or hostname part of private_dns_name
      # :roles,    # tag:Roles.split(',') such as web:app1,db:app1
      # :region,   # ENV['AWS_REGION'],
      # :instance, # Aws::GCE::Types::Instance itself
      #
      # and OPTIONAL_ARRAY_TAGS, OPTIONAL_STRING_TAGS

      extend Forwardable
      def_delegators :instance,
        :instance_id,
        :private_ip_address,
        :public_ip_address,
        :launch_time
      def state; self[:instance].state.name; end
      def monitoring; self[:instance].monitoring.state; end

      alias_method :ip, :private_ip_address
      alias_method :start_date, :launch_time
      def usages; self[:roles]; end

      def self.initialize(instance)
        d = self.new
        d.instance = instance
        d.set_hostname
        d.set_roles
        d.set_region
        d.set_string_tags
        d.set_array_tags
        d
      end

      # match with condition or not
      #
      # @param [Hash] condition search parameters
      def match?(condition)
        return false if !condition[:state] and (terminated? or shutting_down?)
        return false unless role_match?(condition)
        condition = HashUtil.except(condition,
          :role, :role1, :role2, :role3,
          :usage, :usage1, :usage2, :usage3
        )
        condition.each do |key, values|
          v = get_value(key)
          if v.is_a?(Array)
            return false unless v.find {|_| values.include?(_) }
          else
            return false unless values.include?(v)
          end
        end
        true
      end

      def inspect
        sprintf "#<Aws::Host::HostData %s>", info
      end

      def info
        if self[:hostname] and self[:status] and self[:roles] and self[:tags] and self[:service]
          # special treatment for DeNA ;)
          info = "#{self[:hostname]}:#{self[:status]}"
          info << "(#{self[:roles].join(' ')})" unless self[:roles].empty?
          info << "[#{self[:tags].join(' ')}]" unless self[:tags].empty?
          info << "{#{self[:service]}}" unless self[:service].empty?
          info
        else
          to_hash.to_s
        end
      end

      def to_hash
        HashUtil.except(self, :instance).to_h.merge(
          instance_id: instance_id,
          private_ip_address: private_ip_address,
          public_ip_address: public_ip_address,
          launch_time: launch_time,
          state: state,
          monitoring: monitoring,
        )
      end

      # private

      # "instance.instance_id" => self.send("instance").send("instance_id")
      def get_value(key)
        v = self
        key.to_s.split('.').each {|k| v = v[k] || v.send(k) }
        v
      end

      def terminated?
        state == "terminated"
      end

      def shutting_down?
        state == "shutting-down"
      end

      def stopping?
        state == "stopping"
      end

      def stopped
        state == "stopped"
      end

      def running?
        state == "running"
      end

      def pending?
        state == "pending"
      end

      def role_match?(condition)
        # usage is an alias of role
        if role = (condition[:role] || condition[:usage])
          role1, role2, role3 = role.first.split(':')
        else
          role1 = (condition[:role1] || condition[:usage1] || []).first
          role2 = (condition[:role2] || condition[:usage2] || []).first
          role3 = (condition[:role3] || condition[:usage3] || []).first
        end
        if role1
          return false unless self[:roles].find {|role| role.match?(role1, role2, role3) }
        end
        true
      end

      def set_hostname
        self[:hostname] = find_string_tag(Config.hostname_tag)
        self[:hostname] = self[:instance].private_dns_name.split('.').first if self[:hostname].empty?
      end

      def set_roles
        roles  = find_array_tag(Config.roles_tag)
        self[:roles] = roles.map {|role| GCE::Host::RoleData.initialize(role) }
      end

      def set_region
        self[:region] = Config.aws_region
      end

      def set_string_tags
        Config.optional_string_tags.each do |tag|
          field = StringUtil.underscore(tag)
          self[field] = find_string_tag(tag)
        end
      end

      def set_array_tags
        Config.optional_array_tags.each do |tag|
          field = StringUtil.underscore(tag)
          self[field] = find_array_tag(tag)
        end
      end

      def find_string_tag(key)
        v = instance.tags.find {|tag| tag.key == key }
        v ? v.value : ''
      end

      def find_array_tag(key)
        v = instance.tags.find {|tag| tag.key == key }
        v ? v.value.split(Config.array_tag_delimiter) : []
      end
    end
  end
end
