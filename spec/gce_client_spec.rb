require 'spec_helper'

describe GCE::Host::GCEClient do
  let(:client) { GCE::Host::GCEClient.new }
  let(:instances) { client.instances }
  let(:instance) { instances.first }
  let(:name) { instance.name }

  describe '#instances' do
    it do
      expect(instances).not_to be_empty
    end

    it 'filter with name' do
      instances = client.instances(name: name)
      expect(instances).not_to be_empty
      expect(instances.first.name).to eq(name)

      instances = client.instances(name: 'something_not_exist')
      expect(instances).to be_empty
    end

    it 'filter with hostname (alias of name)' do
      instances = client.instances(hostname: name)
      expect(instances).not_to be_empty
      expect(instances.first.name).to eq(name)
    end
  end
end
