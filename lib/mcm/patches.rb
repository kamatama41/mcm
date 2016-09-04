module ActiveRestClient
  class LazyAssociationLoader
    def ensure_lazy_loaded
      if @object.nil?
        req_options = @request.method[:options]
        overridden_name = @options[:overridden_name]
        if (has_many_class = req_options[:has_many][overridden_name])
          object = has_many_class
          method = has_many_class._calls[:list]
        elsif (has_one_class = req_options[:has_one][overridden_name])
          object = has_one_class
          method = has_one_class._calls[:find]
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
        request = ActiveRestClient::Request.new(method, object)
        request.url = request.forced_url = @url
        @object = request.call
      end
    end
  end

  class Request
    def select_name(name, parent_name)
      if name == :self || @method[:options][:has_many][name] || @method[:options][:has_one][name]
        return name
      end

      parent_name || name
    end
  end
end
