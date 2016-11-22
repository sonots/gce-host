require 'gce-host'
require 'optparse'

class GCE
  class Host
    class CLI
      attr_reader :options

      def initialize(argv = ARGV)
        @options = parse_options(argv)
      end

      def parse_options(argv = ARGV)
        op = OptionParser.new

        self.class.module_eval do
          define_method(:usage) do |msg = nil|
            puts op.to_s
            puts "error: #{msg}" if msg
            exit 1
          end
        end

        opts = {
          state: ["running"]
        }

        op.on('--hostname one,two,three', Array, "name") {|v|
          opts[:hostname] = v
        }
        op.on('-r', '--role one,two,three', Array, "role") {|v|
          opts[:role] = v
        }
        op.on('--r1', '--role1 one,two,three', Array, "role1, the 1st part of role delimited by #{Config.role_label_delimiter}") {|v|
          opts[:role1] = v
        }
        op.on('--r2', '--role2 one,two,three', Array, "role2, the 2st part of role delimited by #{Config.role_label_delimiter}") {|v|
          opts[:role2] = v
        }
        op.on('--r3', '--role3 one,two,three', Array, "role3, the 3st part of role delimited by #{Config.role_label_delimiter}") {|v|
          opts[:role3] = v
        }
        op.on('--instance-id one,two,three', Array, "instance_id") {|v|
          opts[:instance_id] = v
        }
        op.on("--#{Config.status} one,two,three", Array, "filter with instance #{Config.status} (default: running)") {|v|
          opts[Config.status.to_sym] = v
        }
        Config.optional_options.keys.each do |opt|
          op.on("--#{opt.to_s.gsub('_', '-')} one,two,three", Array, opt) {|v|
            opts[opt.to_sym] = v
          }
        end
        op.on('-a', '--all', "list all hosts (remove default filter)") {|v|
          [:hostname, :role, :role1, :role2, :role3, :instance_id, Config.status.to_sym].each do |key|
            opts.delete(key)
          end
          Config.optional_options.keys.each do |opt|
            opts.delete(opt.to_sym)
          end
        }
        op.on('--private-ip', '--ip', "show private ip address instead of hostname") {|v|
          opts[:private_ip] = v
        }
        op.on('--public-ip', "show public ip address instead of hostname") {|v|
          opts[:public_ip] = v
        }
        op.on('-i', '--info', "show host info") {|v|
          opts[:info] = v
        }
        op.on('-j', '--jsonl', "show host info in line delimited json") {|v|
          opts[:jsonl] = v
        }
        op.on('--json', "show host info in json") {|v|
          opts[:json] = v
        }
        op.on('--pretty-json', "show host info in pretty json") {|v|
          opts[:pretty_json] = v
        }
        op.on('--debug', "debug mode") {|v|
          opts[:debug] = v
        }
        op.on('-h', '--help', "show help") {|v|
          opts[:help] = v
        }

        begin
          args = op.parse(argv)
        rescue OptionParser::InvalidOption => e
          usage e.message
        end

        if opts[:help]
          usage
        end

        opts
      end

      def run
        hosts = GCE::Host.new(condition)
        if options[:info]
          hosts.each do |host|
            $stdout.puts host.info
          end
        elsif options[:jsonl]
          hosts.each do |host|
            $stdout.puts host.to_hash.to_json
          end
        elsif options[:json]
          $stdout.puts hosts.map(&:to_hash).to_json
        elsif options[:pretty_json]
          $stdout.puts JSON.pretty_generate(hosts.map(&:to_hash))
        elsif options[:private_ip]
          hosts.each do |host|
            $stdout.puts host.private_ip_address
          end
        elsif options[:public_ip]
          hosts.each do |host|
            $stdout.puts host.public_ip_address
          end
        else
          hosts.each do |host|
            $stdout.puts host.hostname
          end
        end
      end

      private

      def condition
        return @condition if @condition
        _condition = HashUtil.except(options, :info, :jsonl, :json, :pretty_json, :debug, :private_ip, :public_ip)
        @condition = {}
        _condition.each do |key, val|
          if label = Config.optional_options[key.to_s]
            field = StringUtil.underscore(label)
            @condition[field.to_sym] = val
          else
            @condition[key.to_sym] = val
          end
        end
        if options[:debug]
          $stderr.puts(options: options)
          $stderr.puts(condition: @condition)
        end
        @condition
      end
    end
  end
end
