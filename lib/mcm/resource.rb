require 'active_rest_client'
require 'mcm/configuration'
require 'mcm/digest_authentication'
require 'mcm/translator'
require 'mcm/patches'

module MCM
  ActiveRestClient::Base.base_url = 'https://cloud.mongodb.com/api/public/v1.0'
  ActiveRestClient::Base.request_body_type = :json
  ActiveRestClient::Base.faraday_config do |c|
    c.use DigestAuthentication
    c.use Faraday::Adapter::NetHttp
  end

  module Resource
    class Base < ActiveRestClient::Base
    end
  end
end

Dir[File.join __dir__, 'resource/**/*.rb'].each { |file| require file }

