class GCE
  class Host
    # Represents each role
    class RoleData
      attr_reader :role1, :role2, :role3

      def initialize(role1, role2 = nil, role3 = nil)
        @role1 = role1
        @role2 = role2
        @role3 = role3
      end

      def self.build(role)
        role1, role2, role3 = role.split(Config.role_value_delimiter, 3)
        new(role1, role2, role3)
      end

      # @return [String] something like "admin:jenkins:slave"
      def role
        @role ||= [role1, role2, role3].compact.reject(&:empty?).join(Config.role_value_delimiter)
      end
      alias :to_s :role

      # @return [Array] something like ["admin", "admin:jenkins", "admin:jenkins:slave"]
      def uppers
        uppers = [RoleData.new(role1)]
        uppers << RoleData.new(role1, role2) if role2 and !role2.empty?
        uppers << RoleData.new(role1, role2, role3) if role3 and !role3.empty?
        uppers
      end

      def match?(role1, role2 = nil, role3 = nil)
        if role3
          role1 == self.role1 and role2 == self.role2 and role3 == self.role3
        elsif role2
          role1 == self.role1 and role2 == self.role2
        else
          role1 == self.role1
        end
      end

      # Equality
      #
      #     Role::Data.new('admin') == Role::Data.new('admin') #=> true
      #     Role::Data.new('admin', 'jenkin') == "admin:jenkins" #=> true
      #
      # @param [Object] other
      def ==(other)
        case other
        when String
          self.role == other
        when GCE::Host::RoleData
          super(other)
        else
          false
        end
      end

      def inspect
        "\"#{to_s}\""
      end
    end
  end
end
