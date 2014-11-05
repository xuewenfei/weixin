module Weixin
  module Storage
    class Base
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def self.init_with(client, storage_type)
        if storage_type == "client"
          ClientStorage.new(client)
        elsif storage_type == "db"
          DbStorage.new(client)
        elsif storage_type == "redis"
          nil
        end
      end

      def valid?
        authenticate["valid"]
      end

      def authenticate
        Rails.logger.debug "Weixin::Storage::Base.authenticate"
        auth_result = http_get_access_token
        auth = false
        if auth_result.is_ok?
          set_access_token_for_client(auth_result.result)
          auth = true
        end
        {"valid" => auth, "handler" => auth_result}
      end

      def refresh_token
        Rails.logger.debug "Weixin::Storage::Base.refresh_token"
        handle_valid_exception
        set_access_token_for_client
      end

      def access_token
        Rails.logger.debug "Weixin::Storage::Base.access_token"
        refresh_token if token_expired?
      end

      def token_expired?
        raise NotImplementedError, "Subclasses must implement a token_expired? method"
      end

      def set_access_token_for_client(access_token_infos=nil)
        Rails.logger.debug "Weixin::Storage::Base.set_access_token_for_client"
        token_infos = access_token_infos || http_get_access_token.result
        client.access_token = token_infos["access_token"]
        client.expired_at   = Time.now.to_i + token_infos["expires_in"].to_i
      end

      def http_get_access_token
        Rails.logger.debug "Weixin::Storage::Base.http_get_access_token"
        Weixin.http_get_without_token("/token", authenticate_headers)
      end

      def authenticate_headers
        {grant_type: Weixin::GRANT_TYPE, appid: client.app_id, secret: client.app_secret}
      end

      private

      def handle_valid_exception
        auth_result =  authenticate
      end

    end

  end

end