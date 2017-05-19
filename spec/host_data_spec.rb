require 'spec_helper'

describe GCE::Host::HostData do
  describe '#role_match?' do
    def host_with_role(role)
      GCE::Host::HostData.new(Object.new).tap do |data|
        roles = [GCE::Host::RoleData.build(role)]
        data.instance_variable_set(:@roles, roles)
      end
    end

    context 'with role' do
      it do
        expect(host_with_role('admin:jenkins:slave').send(:role_match?, role: ['admin'])).to be_truthy
        expect(host_with_role('admin:jenkins:slave').send(:role_match?, role: ['admin:jenkins'])).to be_truthy
        expect(host_with_role('admin:jenkins:slave').send(:role_match?, role: ['admin:jenkins:slave'])).to be_truthy

        expect(host_with_role('foo:a').send(:role_match?, role: ['foo:a', 'bar:b'])).to be_truthy
        expect(host_with_role('bar:a').send(:role_match?, role: ['foo:a', 'bar:b'])).to be_falsey
        expect(host_with_role('foo:b').send(:role_match?, role: ['foo:a', 'bar:b'])).to be_falsey
        expect(host_with_role('bar:b').send(:role_match?, role: ['foo:a', 'bar:b'])).to be_truthy
      end
    end

    context 'with roleN' do
      it do
        expect(host_with_role('foo:a').send(:role_match?, role1: ['foo', 'bar'], role2: ['a', 'b'])).to be_truthy
        expect(host_with_role('bar:a').send(:role_match?, role1: ['foo', 'bar'], role2: ['a', 'b'])).to be_truthy
        expect(host_with_role('baz:a').send(:role_match?, role1: ['foo', 'bar'], role2: ['a', 'b'])).to be_falsey
        expect(host_with_role('foo:b').send(:role_match?, role1: ['foo', 'bar'], role2: ['a', 'b'])).to be_truthy
        expect(host_with_role('bar:b').send(:role_match?, role1: ['foo', 'bar'], role2: ['a', 'b'])).to be_truthy
        expect(host_with_role('baz:b').send(:role_match?, role1: ['foo', 'bar'], role2: ['a', 'b'])).to be_falsey

        expect(host_with_role('foo:a').send(:role_match?, role2: ['a', 'b'])).to be_truthy
        expect(host_with_role('foo:b').send(:role_match?, role2: ['a', 'b'])).to be_truthy
        expect(host_with_role('foo:c').send(:role_match?, role2: ['a', 'b'])).to be_falsey
      end
    end
  end
end
