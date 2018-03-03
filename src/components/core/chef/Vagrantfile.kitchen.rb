require "#{File.dirname(__FILE__)}/../vagrant/Vagrantfile.core"

VM.core(memory: 8192, cpus: 4)

Environment.new(name: 'kitchen.local') do |environment|
  VM.new(environment) do |vm|
    HyperVProvider.new(vm)
    VirtualBoxProvider.new(vm)
  end
end
