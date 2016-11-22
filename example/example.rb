require 'gce-host'
require 'pp'

GCE::Host.new(zone: 'asia-northeast1-a').each do |host|
  pp host
end
