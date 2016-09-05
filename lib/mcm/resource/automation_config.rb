module MCM
  module Resource
    class AutomationConfig < Base
      get :find, '/groups/:id/automationConfig'
      put :update, '/groups/:id/automationConfig'

      def startup(id, process_name)
        p = processes.detect{|p| p.name == process_name}
        if p.disabled
          p.disabled = false
          self.class.update({id: id}.merge(self))
        end
      end

      def startup_all(id)
        processes.each{|p| p.disabled = false}
        self.class.update({id: id}.merge(self))
      end

      def shutdown(id, process_name)
        p = processes.detect{|p| p.name == process_name}
        if p.disabled
          p.disabled =
          self.class.update({id: id}.merge(self))
        end
      end

      def shutdown_all(id)
        processes.each{|p| p.disabled = true}
        self.class.update({id: id}.merge(self))
      end
    end
  end
end
