class GCE
  # Search GCE hosts from tags
  #
  #     require 'gce-host'
  #     # Search by `Name` tag
  #     GCE::Host.new(hostname: 'test').first # => test
  #
  #     # Search by `Roles` tag
  #     GCE::Host.new(
  #       role: 'admin:haikanko',
  #     ).each do |host|
  #       # ...
  #     end
  #
  #     or
  #
  #     GCE::Host.new(
  #       role1: 'admin',
  #       role2: 'haikanko',
  #     ).each do |host|
  #       # ...
  #     end
  #
  #     # Or search
  #     GCE::Host.new(
  #       {
  #           role1: 'db',
  #           role2: 'master',
  #       },
  #       {
  #           role1: 'web',
  #       }
  #     ).each do |host|
  #         # ...
  #     end
  #
  #     GCE::Host.me.hostname # => 'test'
  class Host
    include Enumerable

    # @return [Host::Data] representing myself
    def self.me
      new(instance_id: ClientUtil.instance_id).each do |d|
        return d
      end
      raise 'Not Found'
    end

    # Configure GCE::Host
    #
    # @params [Hash] params see GCE::Host::Config for configurable parameters
    def self.configure(params = {})
      Config.configure(params)
    end

    attr_reader :conditions, :options

    # @param [Array of Hash, or Hash] conditions (and options)
    #
    #     GCE::Host.new(
    #       hostname: 'test',
    #       options: {a: 'b'}
    #     )
    #
    #     GCE::Host.new(
    #       {
    #         hostname: 'foo',
    #       },
    #       {
    #         hostname: 'bar',
    #       },
    #       options: {a: 'b'}
    #     )
    def initialize(*conditions)
      conditions = [{}] if conditions.empty?
      conditions = [conditions] if conditions.kind_of?(Hash)
      @options = {}
      if conditions.size == 1
        @options = conditions.first.delete(:options) || {}
      else
        index = conditions.find_index {|condition| condition.has_key?(:options) }
        @options = conditions.delete_at(index)[:options] if index
      end
      raise ArgumentError, "Hash expected (options)" unless @options.is_a?(Hash)
      @conditions = []
      conditions.each do |condition|
        @conditions << Hash[condition.map {|k, v| [k, Array(v).map(&:to_s)]}]
      end
      raise ArgumentError, "Array of Hash, or Hash expected (conditions)" unless @conditions.all? {|h| h.kind_of?(Hash)}
    end

    # @yieldparam [Host::Data] data entry
    def each(&block)
      @conditions.each do |condition|
        search(ClientUtil.instances(condition), condition, &block)
      end
      return self
    end

    private

    def search(instances, condition)
      instances.each do |i|
        d = GCE::Host::HostData.initialize(i)
        next unless d.match?(condition)
        yield d
      end
    end
  end
end
