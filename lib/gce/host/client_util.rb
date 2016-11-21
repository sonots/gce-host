require 'net/http'
require 'google-api-client'

class GCE
  class Host
    class ClientUtil
      def client
        scope = "https://www.googleapis.com/auth/bigquery"
        client_class = Google::Apis::BigqueryV2::BigqueryService
        return @cached_client if @cached_client && @cached_client_expiration > Time.now

        client = @client_class.new
        client.client_options.application_name = @task['application_name']
        client.request_options.retries = @task['retries']
        client.request_options.timeout_sec = @task['timeout_sec']
        client.request_options.open_timeout_sec = @task['open_timeout_sec']
        Embulk.logger.debug { "embulk-output-bigquery: client_options: #{client.client_options.to_h}" }
        Embulk.logger.debug { "embulk-output-bigquery: request_options: #{client.request_options.to_h}" }

        case @task['auth_method']
        when 'compute_engine'
          auth = Google::Auth::GCECredentials.new
        when 'json_key'
          json_key = @task['json_keyfile']
          if File.exist?(json_key)
            auth = File.open(json_key) do |f|
              Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: f, scope: @scope)
            end
          else
            key = StringIO.new(json_key)
            auth = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: key, scope: @scope)
          end

        when 'application_default'
          auth = Google::Auth.get_application_default([@scope])

        else
          raise ConfigError, "Unknown auth method: #{@task['auth_method']}"
        end

        client.authorization = auth

        @cached_client_expiration = Time.now + 1800
        @cached_client = client
      end

      def self.gce(reload = false)
        if @gce.nil? || reload
          @gce = Aws::GCE::Client.new(region: Config.aws_region, credentials: Config.aws_credentials)
        end
        @gce
      end

      def self.instances(condition)
        describe_instances =
          if instance_id = condition[:instance_id]
            gce.describe_instances(instance_ids: Array(instance_id))
          elsif role = (condition[:role] || condition[:usage]) and role.size == 1
            gce.describe_instances(filters: [{name: "tag:#{Config.roles_tag}", values: ["*#{role.first}*"]}])
          elsif role1 = (condition[:role1] || condition[:usage1]) and role1.size == 1
            gce.describe_instances(filters: [{name: "tag:#{Config.roles_tag}", values: ["*#{role1.first}*"]}])
          elsif role2 = (condition[:role2] || condition[:usage2]) and role2.size == 1
            gce.describe_instances(filters: [{name: "tag:#{Config.roles_tag}", values: ["*#{role2.first}*"]}])
          elsif role3 = (condition[:role3] || condition[:usage3]) and role3.size == 1
            gce.describe_instances(filters: [{name: "tag:#{Config.roles_tag}", values: ["*#{role3.first}*"]}])
          else
            gce.describe_instances
          end
        describe_instances.reservations.map(&:instances).flatten
      end

      def self.instance_id
        return @instance_id if @instance_id
        begin
          http_conn = Net::HTTP.new('169.254.169.254')
          http_conn.open_timeout = 5
          @instance_id = http_conn.start {|http| http.get('/latest/meta-data/instance-id').body }
        rescue Net::OpenTimeout
          raise "HTTP connection to 169.254.169.254 is timeout. Probably, not an GCE instance?"
        end
      end
    end
  end
end
