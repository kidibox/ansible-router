require 'spec_helper'

describe port(67) do
  it { should be_listening.on('0.0.0.0').with('udp') }
end
