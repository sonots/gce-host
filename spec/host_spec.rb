require 'spec_helper'

shared_examples_for 'host' do
  it 'should respond_to' do
    [ :hostname,
      :roles,
      :zone,
      GCE::Host::Config.status.to_sym,
      :service,
      :status,
      :tags,
      :instance,
      :instance_id,
      :private_ip_address,
      :private_ip_addresses,
      :public_ip_address,
      :public_ip_addresses,
      :creation_timestamp,
      :ip,
      :start_date,
      :usages,
    ].each do |k|
      expect(subject.respond_to?(k)).to be_truthy
    end
  end
end

describe GCE::Host do
  describe 'options' do
    context do
      let(:subject) { GCE::Host.new(hostname: 'gce-host-web', options: {foo:'bar'}) }
      it { expect(subject.options).to eq({foo:'bar'}) }
      it { expect(subject.conditions).to eq([{hostname: ['gce-host-web']}]) }
    end

    context do
      let(:subject) { GCE::Host.new({hostname: 'gce-host-web'}, {hostname: 'gce-host-db'}, options: {foo:'bar'}) }
      it { expect(subject.options).to eq({foo:'bar'}) }
      it { expect(subject.conditions).to eq([{hostname: ['gce-host-web']}, {hostname: ['gce-host-db']}]) }
    end
  end

  context '#to_hash' do
    let(:subject) { GCE::Host.new(service: 'gce-host').first.to_hash }

    it 'keys' do
      expect(subject.keys).to eq([
        'hostname',
        'roles',
        'zone',
        'service',
        'status',
        'tags',
        'instance_id',
        'private_ip_address',
        'public_ip_address',
        'creation_timestamp',
        GCE::Host::Config.status,
      ])
    end

    it 'values are not empty' do
      expect(subject.values.any? {|v| v.nil? or (v.respond_to?(:empty?) and v.empty?) }).to be_falsey
    end
  end

  context 'by hostname' do
    let(:hosts) { GCE::Host.new(hostname: 'gce-host-web').to_a }
    let(:subject)  { hosts.first }
    it_should_behave_like 'host'
    it { expect(hosts.size).to eq(1) }
    it { expect(subject.hostname).to eq('gce-host-web') }
  end

  context 'by instance_id' do
    let(:instance_id) { GCE::Host.new(service: 'gce-host').first.instance_id }

    context 'by instance_id' do
      let(:hosts)   { GCE::Host.new(instance_id: instance_id).to_a }
      let(:subject) { hosts.first }
      it_should_behave_like 'host'
      it { expect(hosts.size).to eq(1) }
      it { expect(subject.instance_id).to eq(instance_id) }
    end
  end

  context 'by role' do
    context 'by a role' do
      let(:subject) { GCE::Host.new(role: 'web:test').first }
      it_should_behave_like 'host'
    end

    context 'by a role1' do
      let(:subject) { GCE::Host.new(role1: 'web').first }
      it_should_behave_like 'host'
    end

    context 'by multiple roles (or)' do
      let(:hosts) {
        GCE::Host.new(
          {
            role1: 'web',
            role2: 'test',
          },
          {
            role1: 'db',
            role2: 'test',
          },
        ).to_a
      }
      let(:subject) { hosts.first }
      it { expect(hosts.size).to be >= 2 }
      it_should_behave_like 'host'
    end
  end

  # for compatibility with dino-host
  context 'by usage' do
    context 'by a usage' do
      let(:subject) { GCE::Host.new(usage: 'web:test').first }
      it_should_behave_like 'host'
    end

    context 'by a usage1' do
      let(:subject) { GCE::Host.new(usage1: 'web').first }
      it_should_behave_like 'host'
    end

    context 'by multiple usages (or)' do
      let(:hosts) {
        GCE::Host.new(
          {
            usage1: 'web',
            usage2: 'test',
          },
          {
            usage1: 'db',
            usage2: 'test',
          },
        ).to_a
      }
      let(:subject) { hosts.first }
      it { expect(hosts.size).to be >= 2 }
      it_should_behave_like 'host'
    end
  end

  context 'by status (optional array tags)' do
    context 'by a status' do
      let(:subject) { GCE::Host.new(status: :active).first }
      it_should_behave_like 'host'
    end

    context 'by multiple status (or)' do
      let(:hosts) { GCE::Host.new(status: [:reserve, :active]).to_a }
      let(:subject) { hosts.first }
      it_should_behave_like 'host'
      it { expect(hosts.size).to be >= 2 }
    end

    context 'by a string status' do
      let(:subject) { GCE::Host.new(status: 'active').first }
      it_should_behave_like 'host'
    end

    context 'by multiple string status (or)' do
      let(:hosts) { GCE::Host.new(status: ['reserve', 'active']).to_a }
      let(:subject) { hosts.first }
      it_should_behave_like 'host'
      it { expect(hosts.size).to be >= 2 }
    end
  end

  context 'by service (optional string tags)' do
    context 'by a service' do
      let(:subject) { GCE::Host.new(service: 'gce-host').first }
      it_should_behave_like 'host'
    end

    context 'by multiple services (or)' do
      let(:hosts) { GCE::Host.new(service: ['test', 'gce-host']) }
      let(:subject) { hosts.first }
      it_should_behave_like 'host'
    end
  end

  context 'by tags (optional array tags)' do
    context 'by a tag' do
      let(:subject) { GCE::Host.new(tags: 'master').first }
      it_should_behave_like 'host'
    end

    context 'by multiple tags (or)' do
      let(:hosts) { GCE::Host.new(tags: ['standby', 'master']) }
      let(:subject) { hosts.first }
      it_should_behave_like 'host'
    end
  end
end
