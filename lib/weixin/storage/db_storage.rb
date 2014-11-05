module Weixin
  module Storage
    class DbStorage < Base

      def valid?
        Rails.logger.debug "DbStorage.valid?"
        WeixinAccessToken.destroy_all
        super
      end

      def token_expired?
        Rails.logger.debug "DbStorage.token_expired?"
        access_token = WeixinAccessToken.first
        if access_token.nil?
          true
        else
          Time.now.to_i  > ( access_token.expired_at.to_i - 10 )
        end
      end

      def refresh_token
        Rails.logger.debug "DbStorage.refresh_token"
        super
        WeixinAccessToken.transaction do
          access_token = WeixinAccessToken.new
          access_token.access_token = client.access_token
          access_token.expired_at = client.expired_at
          access_token.save!
        end
      end

      def access_token
        Rails.logger.debug "DbStorage.access_token"
        super
        weixin_access = WeixinAccessToken.first
        unless weixin_access.nil?
          client.access_token = weixin_access.access_token
          client.expired_at = weixin_access.expired_at
        end
        client.access_token
      end
    end
  end
end