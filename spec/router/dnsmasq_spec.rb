require 'spec_helper'

describe port(67) do
  it { should be_listening.on('10.10.0.1').with('udp') }
  it { should_not be_listening.on('192.168.0.2') }
  it { should_not be_listening.on('0.0.0.0') }
end
