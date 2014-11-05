module Weixin
  class Client
    include Api::User

    attr_accessor :app_id, :app_secret, :expired_at # Time.now + expires_in
    attr_accessor :access_token, :redis_key
    attr_accessor :storage

    def initialize(app_id, app_secret, storage_type)
      @app_id = app_id
      @app_secret = app_secret
      @expired_at = Time.now
      @storage = Storage::Base.init_with(self, storage_type)
    end

    def get_access_token
      Rails.logger.debug "Weixin::Cient#get_access_token"
      @storage.access_token
    end

    def is_valid?
      @storage.valid?
    end

    private

    def access_token_param
      {access_token: get_access_token}
    end

    def http_get(url, headers={}, endpoint="plain")
      Rails.logger.debug "client.http_get:url=>#{url}"
      headers = headers.merge(access_token_param)
      Weixin.http_get_without_token(url, headers, endpoint)
    end

    def http_post(url, payload={}, headers={}, endpoint="plain")
      headers = access_token_param.merge(headers)
      Weixin.http_post_without_token(url, payload, headers, endpoint)
    end

    def security_redis_key(key)
      Digest::MD5.hexdigest(key.to_s).upcase
    end

  end
end