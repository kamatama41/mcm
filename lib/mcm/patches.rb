module ActiveRestClient
  class LazyAssociationLoader
    def ensure_lazy_loaded
      if @object.nil?
        req_options = @request.method[:options]
        overridden_name = @options[:overridden_name]
        if (has_many_class = req_options[:has_many][overridden_name])
          object = has_many_class.constantize
          method = object._calls[:list]
        elsif (has_one_class = req_options[:has_one][overridden_name])
          object = has_one_class.constantize
          method = object._calls[:find]
        else
          object = @request.object
          method = MultiJson.load(MultiJson.dump(@request.method),:symbolize_keys => true)
          method[:method] = :get
          method[:options][:lazy] = @request.method[:options][:lazy]
          method[:options][:has_many] = @request.method[:options][:has_many]
          method[:options][:has_one] = @request.method[:options][:has_one]
          method[:options][:overridden_name] = overridden_name
        end
        method[:options][:url] = @url
        @lazy_request = ActiveRestClient::Request.new(method, object)
        @lazy_request.url = @lazy_request.forced_url = @url
        @object = @lazy_request.call
      end
    end

    # To prevent infinite loop
    def to_json
      ensure_lazy_loaded
      @lazy_request.response.body
    end
  end

  class Request
    attr_reader :response

    def select_name(name, parent_name)
      if name == :self || @method[:options][:has_many][name] || @method[:options][:has_one][name]
        return name
      end
      parent_name || name
    end
  end
end
