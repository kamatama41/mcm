module MCM
  module Resource
    class AutomationConfig < Base
      whiny_missing false
      get :find, '/groups/:id/automationConfig'
      put :update, '/groups/:id/automationConfig'

      def startup(id, process_names)
        process_names = [process_names] unless process_names.is_a? Array
        updated = false
        processes.each do |p|
          if process_names.include? p.name and p.disabled
            p.disabled = false
            updated = true
          end
        end
        if updated
          self.class.update({id: id}.merge(self))
        end
      end

      def startup_all(id)
        startup(id, processes.map(&:name))
      end

      def shutdown(id, process_names)
        process_names = [process_names] unless process_names.is_a? Array
        updated = false
        processes.each do |p|
          if process_names.include? p.name and !p.disabled
            p.disabled = true
            updated = true
          end
        end
        if updated
          self.class.update({id: id}.merge(self))
        end
      end

      def shutdown_all(id)
        shutdown(id, processes.map(&:name))
      end
    end
  end
end
