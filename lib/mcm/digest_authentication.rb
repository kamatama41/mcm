require 'net/http/digest_auth'
require 'faraday/middleware'

module MCM
  class DigestAuthentication < Faraday::Middleware
    def call(env)
      set_digest(env)
      @app.call(env)
    end

    def set_digest(env)
      digest_auth = Net::HTTP::DigestAuth.new
      digest_auth.next_nonce

      uri = env.url
      uri.user = URI.encode_www_form_component(ENV['MCM_USER'])
      uri.password = URI.encode_www_form_component(ENV['MCM_TOKEN'])

      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true

      req = "Net::HTTP::#{env.method.to_s.camelize}".constantize.new(uri)
      res = http.request(req)

      raise "Unexpected status #{res.code}: #{res.message}" unless res.code.to_s == '401'
      env.request_headers['Authorization'] = digest_auth.auth_header(uri, res['www-authenticate'], req.method)
    end
  end
end
