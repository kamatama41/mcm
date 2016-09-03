require 'spec_helper'

describe MCM::Resource::Root do
  it 'gets a root resource' do
    res = MCM::Resource::Root.index
    puts res.links
  end
end
