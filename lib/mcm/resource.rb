require 'active_rest_client'
require 'mcm/digest_authentication'

module MCM
  ActiveRestClient::Base.base_url = 'https://cloud.mongodb.com/api/public/v1.0'
  ActiveRestClient::Base.faraday_config do |c|
    c.use DigestAuthentication
    c.use Faraday::Request::UrlEncoded
    c.use Faraday::Adapter::NetHttp
  end

  module Resource
    class Base < ActiveRestClient::Base
    end
  end
end

Dir[File.join __dir__, 'resource/**/*.rb'].each { |file| require file }

