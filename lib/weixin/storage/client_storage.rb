module Weixin
  module Storage
    class ClientStorage < Base

      def valid?
        super
      end

      def token_expired?
        # 如果当前token过期时间小于现在的时间，则重新获取一次
        client.expired_at <= Time.now.to_i
      end

      def refresh_token
        super
      end

      def access_token
        super
        client.access_token
      end

    end
  end

end