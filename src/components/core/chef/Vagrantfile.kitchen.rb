require "#{File.dirname(__FILE__)}/../vagrant/Vagrantfile.core"

VM.core(memory: 8192, cpus: 2)

Environment.new(name: 'kitchen.local') do |environment|
  VM.new(environment) do |vm|
    VirtualBoxProvider.new(vm)
  end
end
