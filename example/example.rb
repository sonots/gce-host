require 'gce-host'
require 'pp'

GCE::Host.new(role1: 'admin').each do |host|
  pp host
end
