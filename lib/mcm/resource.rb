require 'active_rest_client'
require 'mcm/digest_authentication'
require 'mcm/translator'
require 'mcm/patches'

module MCM
  ActiveRestClient::Base.base_url = 'https://cloud.mongodb.com/api/public/v1.0'
  ActiveRestClient::Base.faraday_config do |c|
    c.use DigestAuthentication
    c.use Faraday::Adapter::NetHttp
  end

  module Resource
    class Base < ActiveRestClient::Base
      class << self
        def get(name, url, opts = {})
          opts[:lazy] ||= []
          opts[:has_many] ||= []
          opts[:has_one] ||= []

          options = {
            lazy: ([:self] + opts[:lazy] + opts[:has_many] + opts[:has_one]).uniq
          }
          %i(has_many has_one).each do |s|
            f = opts[s].map{|k| [k, "MCM::Resource::#{k.to_s.singularize.camelize}"] }.flatten
            options[s] = Hash[*f]
          end
          _map_call(name, url:url, method: :get, options:options)
        end

        def translator
          @translator ||= Translator.new
        end
      end
    end
  end
end

Dir[File.join __dir__, 'resource/**/*.rb'].each { |file| require file }

