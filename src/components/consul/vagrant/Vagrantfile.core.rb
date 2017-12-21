require "#{File.dirname(__FILE__)}/../../core/vagrant/Vagrantfile.core"

class ConsulServerChefSoloProvisioner < ChefSoloProvisioner
  @@consul_server = {
    'run_list' => 'gusztavvargadr_consul::server',
  }

  def self.consul_server(options = {})
    @@consul_server = @@consul_server.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@consul_server.deep_merge(options))
  end

  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_consul' => {
        'server' => {
          'config' => {
            'options' => {
              'node_name' => vm.hostname,
              'bootstrap_expect' => options['json']['gusztavvargadr_consul']['server']['config']['options']['retry_join'].count,
            },
          },
        },
      }
    )
  end
end

class ConsulClientChefSoloProvisioner < ChefSoloProvisioner
  @@consul_client = {
    'run_list' => 'gusztavvargadr_consul::client',
  }

  def self.consul_client(options = {})
    @@consul_client = @@consul_client.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@consul_client.deep_merge(options))
  end

  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_consul' => {
        'client' => {
          'config' => {
            'options' => {
              'node_name' => vm.hostname,
            },
          },
        },
      }
    )
  end
end
