require 'spec_helper'

describe port(67) do
  it { should be_listening.with('udp') }
end
