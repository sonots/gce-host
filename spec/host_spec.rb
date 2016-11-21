require 'spec_helper'

shared_examples_for 'host' do
  it 'should have parameters' do
    [ :hostname,
      :roles,
      :status,
      :tags,
      :service,
      :region,
      :instance,
      :instance_id,
      :private_ip_address,
      :public_ip_address,
      :launch_time,
      :state,
      :monitoring,
      :ip,
      :start_date,
      :usages,
    ].each do |k|
      expect{ subject.__send__(k) }.not_to raise_error
    end
  end
end

describe GCE::Host do
  describe 'options' do
    context do
      let(:subject) { GCE::Host.new(hostname: 'test', options: {foo:'bar'}) }
      it { expect(subject.options).to eq({foo:'bar'}) }
      it { expect(subject.conditions).to eq([{hostname: ['test']}]) }
    end

    context do
      let(:subject) { GCE::Host.new({hostname: 'foo'}, {hostname: 'bar'}, options: {foo:'bar'}) }
      it { expect(subject.options).to eq({foo:'bar'}) }
      it { expect(subject.conditions).to eq([{hostname: ['foo']}, {hostname: ['bar']}]) }
    end
  end

  describe '#get_value' do
    let(:hosts) { GCE::Host.new(instance_id: 'i-85900780').to_a }
    let(:subject)  { hosts.first }
    it { expect(subject.get_value('instance.instance_id')).to eql('i-85900780') }
  end

  context 'by instance_id' do
    let(:hosts) { GCE::Host.new(instance_id: 'i-85900780').to_a }
    let(:subject)  { hosts.first }
    it_should_behave_like 'host'
    it { expect(hosts.size).to eq(1) }
    it { expect(subject.hostname).to eq('test') }
  end

  context 'by hostname' do
    let(:hosts) { GCE::Host.new(hostname: 'test').to_a }
    let(:subject)  { hosts.first }
    it_should_behave_like 'host'
    it { expect(hosts.size).to eq(1) }
    it { expect(subject.hostname).to eq('test') }
  end

  context 'by role' do
    context 'by a role' do
      let(:subject) { GCE::Host.new(role: 'admin:ami').first }
      it_should_behave_like 'host'
    end

    context 'by a role1' do
      let(:subject) { GCE::Host.new(role1: 'admin').first }
      it_should_behave_like 'host'
    end

    context 'by multiple roles (or)' do
      let(:hosts) {
        GCE::Host.new(
          {
            role1: 'admin',
            role2: 'ami',
          },
          {
            role1: 'isucon4',
          }
        ).to_a
      }
      let(:subject) { hosts.first }
      it { expect(hosts.size).to be >= 2 }
      it_should_behave_like 'host'
    end
  end

  # This is for DeNA use
  context 'by usage (an alias of usage)' do
    context 'by a usage' do
      let(:subject) { GCE::Host.new(usage: 'admin:ami').first }
      it_should_behave_like 'host'
    end

    context 'by a usage1' do
      let(:subject) { GCE::Host.new(usage1: 'admin').first }
      it_should_behave_like 'host'
    end

    context 'by multiple usages (or)' do
      let(:hosts) {
        GCE::Host.new(
          {
            usage1: 'admin',
            usage2: 'ami',
          },
          {
            usage1: 'isucon4',
          }
        ).to_a
      }
      let(:subject) { hosts.first }
      it { expect(hosts.size).to be >= 2 }
      it_should_behave_like 'host'
    end
  end

  context 'by status' do
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

  context 'by service' do
    context 'by a service' do
      let(:subject) { GCE::Host.new(service: 'isucon4').first }
      it_should_behave_like 'host'
    end

    context 'by multiple services (or)' do
      let(:hosts) { GCE::Host.new(service: ['test', 'isucon4']) }
      let(:subject) { hosts.first }
      it_should_behave_like 'host'
    end
  end

  context 'by region' do
    context 'by a region' do
      let(:subject) { GCE::Host.new(region: 'ap-northeast-1').first }
      it_should_behave_like 'host'
    end

    context 'by multiple regions (or)' do
      let(:hosts) { GCE::Host.new(region: ['ap-northeast-1']) }
      let(:subject) { hosts.first }
      it_should_behave_like 'host'
    end
  end

  context 'by tags' do
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
