module MCM
  class Translator
    def method_missing(_, body)
      replace_hash_keys(body)
    end

    private
    def replace_hash_keys(object)
      if object.is_a? Hash
        result = {}
        object.each {|k, v| result[k.underscore] = replace_hash_keys(v)}
        handle_links(result)
      elsif object.is_a? Array
        object.map {|e| replace_hash_keys(e)}
      else
        object
      end
    end

    def handle_links(body)
      if body['links']
        body['links'].each do |link|
          rel = link['rel'].gsub(/http:\/\/mms\.mongodb\.com\//, '')
          body[rel.underscore] = link
        end
        body.delete('links')
      end
      body
    end
  end
end
