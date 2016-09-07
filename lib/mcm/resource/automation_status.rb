module MCM
  module Resource
    class AutomationStatus < Base
      get :find, '/groups/:id/automationStatus'

      def self.wait_for_goal(group_id, options={})
        max_attempts = options[:max_attempts] || 10
        wait_seconds = options[:wait_seconds] || 30
        attempts = 0
        until (deploying_processes = find(group_id).deploying_processes).empty?
          raise 'Timeout' if attempts == max_attempts
          attempts += 1
          puts "Following processes are deploying yet. Wait #{wait_seconds} seconds... (#{attempts}/#{max_attempts})"
          puts "#{deploying_processes.map(&:name)}"
          sleep wait_seconds
        end
        puts 'All hosts have been deployed!'
      end

      def deploying_processes
        processes.select do |p|
          p.last_goal_version_achieved != goal_version
        end
      end
    end
  end
end
