require 'spec_helper'

describe MCM::Resource::AutomationConfig do
  it 'gets and updates a resource' do
    group = MCM::Resource::Group.list.results[3]
    config = MCM::Resource::AutomationConfig.find(group.id)
    process = config.processes[0]
    begin
      config.startup(group.id, process.name)
    rescue => e
      puts e.result.to_json
      puts e.request_url
      raise e
    end
    config.processes.each do |p|
      puts p.name
      puts p.disabled
    end
    config.shutdown_all(group.id)
  end
end
