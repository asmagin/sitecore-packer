require "#{File.dirname(__FILE__)}/../../../../Vagrantfile.core"

class VaultServer
  @@defaults = {
    type: 'server',
    synced_folder_destination: '/vagrant-parent',
    docker_image_name: 'local/vault',
  }

  attr_reader :options

  def initialize(vm, options = {})
    @options = @@defaults.deep_merge(options)

    vm.vagrant.vm.synced_folder "#{File.dirname(__FILE__)}/..", @options[:synced_folder_destination]

    DockerProvisioner.new(
      vm,
      builds: [
        {
          path: "#{@options[:synced_folder_destination]}/docker/cli",
          args: "-t #{@options[:docker_image_name]}:cli",
        },
        {
          path: "#{@options[:synced_folder_destination]}/docker/#{@options[:type]}",
          args: "-t #{@options[:docker_image_name]}:#{@options[:type]}",
        },
      ],
      runs: [
        {
          container: "vault-#{@options[:docker_image_name]}",
          image: "#{@options[:docker_image_name]}:#{@options[:type]}",
          args: docker_run_args(vm),
          cmd: 'server',
          restart: 'unless-stopped',
        },
      ],
      run: 'always'
    )
  end

  def docker_run_args(vm)
    args = [
      '--network host',
      "--hostname #{vm.hostname}",
      "--env 'VAULT_LOCAL_CONFIG=#{docker_run_args_local_config(vm).to_json}'",
      "--env 'VAULT_ADDR=https://#{vm.hostname}:8200'",
      "--env 'VAULT_TOKEN=#{vm.environment.options[:vault][:token]}'",
    ]
    args.join(' ')
  end

  def docker_run_args_local_config(vm)
    {
      backend: {
        consul: {
          address: vm.environment.options[:consul][:address],
          scheme: vm.environment.options[:consul][:scheme],
          path: vm.environment.options[:consul][:path],
          token: vm.environment.options[:consul][:token],
        },
      },
    }
  end
end

class VaultUi
  def initialize(vm, options = {})
    vm.vagrant.vm.synced_folder '.', '/vagrant', disabled: true

    server = options[:vault][:servers][0]

    vm.vagrant.vm.provider 'docker' do |d|
      d.build_dir = "#{File.dirname(__FILE__)}/../docker/ui"
      d.env = {
        'VAULT_URL_DEFAULT' => "https://#{server}:8200",
        'VAULT_AUTH_DEFAULT' => 'TOKEN',
        'NODE_TLS_REJECT_UNAUTHORIZED' => 0,
      }
      d.create_args = ['--network', 'host']
    end
  end
end

class VaultCli
  def initialize(vm, options = {})
    vm.vagrant.vm.synced_folder '.', '/vagrant', disabled: true

    server = options[:vault][:servers][0]

    vm.vagrant.vm.provider 'docker' do |d|
      d.build_dir = "#{File.dirname(__FILE__)}/../docker/cli"
      d.env = {
        'VAULT_ADDR' => "https://#{server}:8200",
        'VAULT_TOKEN' => vm.environment.options[:vault][:token],
      }
      d.create_args = ['--network', 'host']
      d.cmd = ['vault', 'mounts']
      d.remains_running = false
    end
  end
end
