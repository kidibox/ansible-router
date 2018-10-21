require 'rake'
require 'rspec/core/rake_task'

hosts = %w[
  router
  client1
  client2
]

task spec: 'spec:all'

namespace :spec do
  task all: hosts.map { |h| 'spec:' + h.split('.')[0] }
  hosts.each do |host|
    role = host.split('.')[0]

    desc "Run serverspec to #{host}"
    RSpec::Core::RakeTask.new(role) do |t|
      ENV['TARGET_HOST'] = host
      t.pattern = "spec/{base,#{role}}/*_spec.rb"
    end
  end
end
