module ActiveRestClient
  class Base
    class << self
      def _map_call(name, details)
        details[:options] = replace_options(details[:options])
        _calls[name] = {name:name}.merge(details)
        _calls["lazy_#{name}".to_sym] = {name:name}.merge(details)
        self.class.send(:define_method, name) do |options={}|
          _call(name, options)
        end
        self.class.send(:define_method, "lazy_#{name}".to_sym) do |options={}|
          _call("lazy_#{name}", options)
        end
      end

      def replace_options(opts)
        %i(lazy has_many has_one).each do |s|
          opts[s] ||= []
          opts[s] = opts[s].map{|e| e.to_s.camelize(:lower).to_sym }
        end

        options = {
          lazy: ([:self] + opts[:lazy] + opts[:has_many] + opts[:has_one]).uniq
        }
        %i(has_many has_one).each do |s|
          f = opts[s].map{|k| [k, "MCM::Resource::#{k.to_s.singularize.camelize}"] }.flatten
          options[s] = Hash[*f]
        end
        options
      end

      def translator
        @translator ||= MCM::Translator.new
      end

      def whiny_missing(value = nil)
        if value
          @whiny_missing = value
        else
          @whiny_missing
        end
      end
    end

    def method_missing(name, *args)
      name = name.to_s.camelize(:lower).to_sym
      if name.to_s[-1,1] == "="
        name = name.to_s.chop.to_sym
        @attributes[name] = args.first
        @dirty_attributes << name
      else
        name_sym = name.to_sym
        name = name.to_s

        if @attributes.has_key? name_sym
          @attributes[name_sym]
        else
          if name[/^lazy_/] && mapped = self.class._mapped_method(name_sym)
            raise ValidationFailedException.new unless valid?
            request = Request.new(mapped, self, args.first)
            ActiveRestClient::LazyLoader.new(request)
          elsif mapped = self.class._mapped_method(name_sym)
            raise ValidationFailedException.new unless valid?
            request = Request.new(mapped, self, args.first)
            request.call
          elsif self.class.whiny_missing
            raise NoAttributeException.new("Missing attribute #{name_sym}")
          else
            nil
          end
        end
      end
    end
  end

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
