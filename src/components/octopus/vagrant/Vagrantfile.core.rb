require "#{File.dirname(__FILE__)}/../../core/vagrant/Vagrantfile.core"

class OctopusServerChefSoloProvisioner < ChefSoloProvisioner
  @@octopus_server = {
    'json' => {
      'gusztavvargadr_octopus' => {
        'server' => {
          'execute_username' => 'vagrant',
          'execute_password' => 'vagrant',
          'web_username' => 'vagrant',
          'web_password' => 'Vagrant42',
        },
      },
    },
  }

  def self.octopus_server(options = {})
    @@octopus_server = @@octopus_server.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@octopus_server.deep_merge(options))
  end

  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_octopus' => {
        'server' => {
          'web_addresses' => [
            'http://localhost',
            "http://#{vm.hostname}",
          ],
          'node_name' => vm.hostname,
        },
      }
    )
  end
end

class OctopusTentacleChefSoloProvisioner < ChefSoloProvisioner
  @@octopus_tentacle = {
    'json' => {
      'gusztavvargadr_octopus' => {
        'tentacle' => {
          'execute_username' => 'vagrant',
          'execute_password' => 'vagrant',
        },
      },
    },
  }

  def self.octopus_server(options = {})
    @@octopus_tentacle = @@octopus_tentacle.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@octopus_tentacle.deep_merge(options))
  end

  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_octopus' => {
        'tentacle' => {
          'node_name' => vm.hostname,
          'public_hostname' => vm.hostname,
        },
      }
    )
  end
end
