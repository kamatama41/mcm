require 'spec_helper'

describe MCM::Resource::Root do
  it 'gets a root resource' do
    root = MCM::Resource::Root.find
    groups = root.groups
    groups.each do |g|
      puts "name:#{g.name}, id:#{g.id}"
    end
  end
end
