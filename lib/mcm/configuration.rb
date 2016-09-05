module MCM
  class Configuration
    attr_accessor :user, :token
  end

  def config
    @config ||= Configuration.new
    if block_given?
      yield @config
    end
    @config
  end
  module_function :config
end
