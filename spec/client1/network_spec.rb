require 'spec_helper'

describe interface('eth1') do
  it { should be_up }
  its(:ipv4_address) { should match %r/10\.2\.0\.\d{3}\/24/ }
end

describe host('router') do
  it { should be_resolvable.by('dns') }
  it { should be_reachable }
end

describe host('client2') do
  it { should be_resolvable.by('dns') }
  it { should be_reachable }
end

describe host('ifconfig.co') do
  it { should be_reachable.with(port: 443) }
end
