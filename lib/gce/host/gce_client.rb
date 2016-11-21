require_relative 'version'
require 'google/apis/compute_beta' # required to filter nested fields

class GCE
  class Host
    class GCEClient
      def client(reload = false)
        return @cached_client if @cached_client && @cached_client_expiration > Time.now && !reload

        scope = "https://www.googleapis.com/auth/compute.readonly"
        client = Google::Apis::ComputeBeta::ComputeService.new
        client.client_options.application_name = 'gce-host'
        client.client_options.application_name = GCE::Host::VERSION
        client.request_options.retries = Config.retries
        client.request_options.timeout_sec = Config.timeout_sec
        client.request_options.open_timeout_sec = Config.open_timeout_sec

        case Config.auth_method
        when 'compute_engine'
          auth = Google::Auth::GCECredentials.new

        when 'json_key'
          json_key = Config.json_keyfile
          auth = File.open(json_key) do |f|
            Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: f, scope: scope)
          end

        when 'application_default'
          auth = Google::Auth.get_application_default([scope])

        else
          raise ConfigError, "Unknown auth method: #{Config.auth_method}"
        end

        client.authorization = auth

        @cached_client_expiration = Time.now + 1800
        @cached_client = client
      end

      def list_instances(condition = {})
        filter = build_filter(condition)
        instances = []
        res = client.list_aggregated_instances(Config.project_id, filter: filter)
        instances.concat(res.items.values.map(&:instances).compact.flatten(1))
        while res.next_page_token
          res = client.list_aggregated_instances(Config.project_id, filter: filter, page_token: res.next_page_token)
          instances.concat(res.items.values.map(&:instances).compact.flatten(1))
        end
        instances
      end

      private
      
      def build_filter(condition)
        if name = condition[:name]
          "name eq #{name}"
        elsif role = (condition[:role] || condition[:usage]) and role.size == 1
          "labels.roles eq .*#{Regexp.escape(Array(role).first)}.*"
        elsif role1 = (condition[:role1] || condition[:usage1]) and role1.size == 1
          "labels.roles eq .*#{Regexp.escape(Array(role1).first)}.*"
        elsif role2 = (condition[:role2] || condition[:usage2]) and role2.size == 1
          "labels.roles eq .*#{Regexp.escape(Array(role2).first)}.*"
        elsif role3 = (condition[:role3] || condition[:usage3]) and role3.size == 1
          "labels.roles eq .*#{Regexp.escape(Array(role3).first)}.*"
        else
          nil
        end
      end
    end
  end
end
