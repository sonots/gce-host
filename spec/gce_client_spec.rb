require 'spec_helper'

# REQUIREMENT:
#
# 1. Configure .env as example/example.json
# 2. Create a GCE instance on your project
# 3. Configure labels for the instance to have `roles: step`
describe GCE::Host::GCEClient do
  let(:client) { GCE::Host::GCEClient.new }

  describe '#list_instances' do
    it do
      instances = client.list_instances
      expect(instances).not_to be_empty
    end

    it 'filter with name' do
      instances = client.list_instances
      name = instances.first.name

      instances = client.list_instances(name: name)
      expect(instances).not_to be_empty
      expect(instances.first.name).to eq(name)

      instances = client.list_instances(name: 'something_not_exist')
      expect(instances).to be_empty
    end

    it 'filter with role' do
      instances = client.list_instances(role: ['step'])
      expect(instances).not_to be_empty
      instances.each do |instance|
        expect(instance.metadata.items.find {|item| item.key == 'roles' }.value).to include('step')
      end

      instances = client.list_instances(role: ['something_not_exist'])
      expect(instances).to be_empty
    end
  end
end
