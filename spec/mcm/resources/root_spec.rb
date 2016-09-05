require 'spec_helper'

describe MCM::Resource::Root do
  it 'gets a root resource' do
    root = MCM::Resource::Root.find

    puts root.user.to_json
    u = MCM::Resource::User.find_by_name(root.user.username)
    puts u.first_name

    puts root.groups.to_json
    groups = root.groups.self
    groups.results.each do |g|
      puts "name:#{g.name}, active_agent_count:#{g.active_agent_count}"
    end
  end
end
