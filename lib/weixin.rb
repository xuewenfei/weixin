require "rest-client"

module Weixin
  OK_MSG     = "ok".freeze
  OK_CODE    = 0.freeze
  GRANT_TYPE = "client_credential".freeze

  class << self
    def http_get_without_token(url, headers={}, endpoint="plain")
      Rails.logger.debug "Weixin.http_get_without_token:"
      pp headers
      get_api_url = endpoint_url(endpoint, url)
      load_json(RestClient.get(get_api_url, :params => headers))
    end

    def http_post_without_token(url, payload={}, headers={}, endpoint="plain")
      post_api_url = endpoint_url(endpoint, url)
      payload = JSON.dump(payload) if endpoint == "plain" # to json if invoke "plain"
      load_json(RestClient.post(post_api_url, payload, :params => headers))
    end

    # return hash
    def load_json(string)
      result_hash = JSON.parse(string)
      code   = result_hash.delete("errcode")
      en_msg = result_hash.delete("errmsg")
      Weixin::Handler::ResultHandler.new(code, en_msg, result_hash)
    end

    def endpoint_url(endpoint, url)
      send("#{endpoint}_endpoint") + url
    end

    def plain_endpoint
      "https://api.weixin.qq.com/cgi-bin"
    end

    def file_endpoint
      "http://file.api.weixin.qq.com/cgi-bin"
    end

    def mp_endpoint(url)
      "https://mp.weixin.qq.com/cgi-bin#{url}"
    end
  end

end