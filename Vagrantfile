require "#{File.dirname(__FILE__)}/src/components/core/vagrant/Vagrantfile.core"

Environment.new(name: 'packer.local') do |environment|
  create_packer_vms(environment, 'w16s')
  create_packer_vms(environment, 'w16s-dotnet')
  create_packer_vms(environment, 'w16s-iis')
end

def create_packer_vms(environment, name)
  create_local_packer_vm(environment, name, 'core')
  create_local_packer_vm(environment, name, 'sysprep')

  create_cloud_packer_vm(environment, name)
end

def create_local_packer_vm(environment, name, type)
  PackerVM.new(environment, name: "#{name}-#{type}", box: "local/#{name}-#{type}") do |vm|
    VirtualBoxProvider.new(vm) do |provider|
      provider.override.vm.box_url = "file://#{File.dirname(__FILE__)}/build/#{name}/virtualbox-#{type}/output/vagrant.box"
    end
  end
end

def create_cloud_packer_vm(environment, name)
  PackerVM.new(environment, name: "#{name}-cloud", box: "scp/#{name}") do |vm|
    VirtualBoxProvider.new(vm)
  end
end

class PackerVM < VM
  @@packer = {
    autostart: false,
    memory: 8192,
    cpus: 4,
    linked_clone: false,
  }

  def self.packer(options = {})
    @@packer = @@packer.deep_merge(options)
  end

  def initialize(environment, options = {})
    super(environment, @@packer.deep_merge(options))
  end
end
