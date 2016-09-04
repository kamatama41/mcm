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
          opts[:has_many] ||= {}
          opts[:has_one] ||= {}

          (opts[:has_many].keys + opts[:has_one].keys + [:self]).each do |k|
            opts[:lazy] << k unless opts[:lazy].include?(:self)
          end

          _map_call(name, url:url, method: :get, options:opts)
        end
      end

      def each
        if (results = @attributes[:results])
          results.each do |value|
            yield value
          end
        else
          yield self
        end
      end

      def self.translator
        @translator ||= Translator.new
      end
    end
  end
end

Dir[File.join __dir__, 'resource/**/*.rb'].each { |file| require file }

