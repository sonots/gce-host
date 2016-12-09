require_relative 'version'
require 'google/apis/compute_v1'

class GCE
  class Host
    class GCEClient
      class Error < ::StandardError; end
      class NotFound < Error; end

      def instances(condition = {})
        filter = build_filter(condition)
        instances = []
        res = client.list_aggregated_instances(Config.project, filter: filter)
        instances.concat(res.items.values.map(&:instances).compact.flatten(1))
        while res.next_page_token
          res = client.list_aggregated_instances(Config.project, filter: filter, page_token: res.next_page_token)
          instances.concat(res.items.values.map(&:instances).compact.flatten(1))
        end
        instances
      end

      private

      def client
        return @client if @client && @client_expiration > Time.now

        scope = "https://www.googleapis.com/auth/compute.readonly"
        client = Google::Apis::ComputeV1::ComputeService.new
        client.client_options.application_name = 'gce-host'
        client.client_options.application_version = GCE::Host::VERSION
        client.request_options.retries = Config.retries
        client.request_options.timeout_sec = Config.timeout_sec
        client.request_options.open_timeout_sec = Config.open_timeout_sec

        case Config.auth_method
        when 'compute_engine'
          auth = Google::Auth::GCECredentials.new

        when 'service_account'
          auth = File.open(Config.credentials_file) do |f|
            Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: f, scope: scope)
          end

        when 'authorized_user'
          auth = File.open(Config.credentials_file) do |f|
            Google::Auth::UserRefreshCredentials.make_creds(json_key_io: f, scope: scope)
          end

        when 'application_default'
          auth = Google::Auth.get_application_default([scope])

        else
          raise ConfigError, "Unknown auth method: #{Config.auth_method}"
        end

        client.authorization = auth

        @client_expiration = Time.now + 1800
        @client = client
      end

      # MEMO: OR did not work
      # MEMO: filter for metadata and tags did not work (metadata.items[0].value eq role)
      def build_filter(condition)
        if names = (condition[:name] || condition[:hostname]) and Array(names).size == 1
          "name eq #{Array(names).first}"
        else
          nil
        end
      end
    end
  end
end
