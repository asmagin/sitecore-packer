require 'yaml'
require 'erb'

class Options
  attr_reader :options
  attr_reader :directory

  def initialize(directory)
    @directory = directory
    @options = {}

    Dir.glob("#{@directory}/vagrant*.yml").sort_by { |file| File.basename(file, '.*') }.each do |file|
      @options = @options.deep_merge(YAML.load(ERB.new(File.read(file)).result) || {})
    end
  end
end

class Environment
  @@core = {
    name: 'local',
    hostmanager: {
      host: false,
      guest: false,
    },
  }

  def self.core(options = {})
    @@core = @@core.deep_merge(options)
  end

  attr_reader :options
  attr_reader :vagrant

  def initialize(options = {})
    @options = @@core.deep_merge(options)

    Vagrant.configure('2') do |vagrant|
      @vagrant = vagrant

      vagrant_configure

      yield self if block_given?
    end
  end

  def vagrant_configure
    vagrant.hostmanager.enabled = hostmanager_enabled?
    vagrant.hostmanager.manage_host = options[:hostmanager][:host]
    vagrant.hostmanager.manage_guest = options[:hostmanager][:guest]
  end

  def hostmanager_enabled?
    options[:hostmanager][:host] || options[:hostmanager][:guest]
  end
end

class VM
  @@core = {
    name: 'default',
    box: '',
    autostart: true,
    primary: false,
    memory: 8192,
    cpus: 4,
    linked_clone: true,
  }

  def self.core(options = {})
    @@core = @@core.deep_merge(options)
  end

  attr_reader :options
  attr_reader :vagrant
  attr_reader :environment

  def initialize(environment, options = {})
    @options = @@core.deep_merge(options)
    @environment = environment

    @environment.vagrant.vm.define @options[:name], vagrant_options do |vagrant|
      @vagrant = vagrant

      vagrant_configure

      yield self if block_given?
    end
  end

  def vagrant_options
    {
      autostart: options[:autostart],
      primary: options[:primary],
    }
  end

  def vagrant_configure
    vagrant.vm.box = options[:box] unless options[:box].to_s.empty?
    vagrant.hostmanager.aliases = [hostname] if environment.hostmanager_enabled?
  end

  def hostname
    "#{options[:name]}.#{environment.options[:name]}"
  end
end

class Provider
  @@core = {
    type: '',
  }

  def self.core(options = {})
    @@core = @@core.deep_merge(options)
  end

  attr_reader :options
  attr_reader :vagrant
  attr_reader :override
  attr_reader :vm

  def initialize(vm, options = {})
    @options = @@core.deep_merge(options)
    @vm = vm

    @vm.vagrant.vm.provider @options[:type] do |vagrant, override|
      @vagrant = vagrant
      @override = override

      vagrant_configure

      yield self if block_given?
    end
  end

  def vagrant_configure
    vagrant.memory = vm.options[:memory]
    vagrant.cpus = vm.options[:cpus]
  end
end

class VirtualBoxProvider < Provider
  @@virtualbox = {
    type: 'virtualbox',
  }

  def self.virtualbox(options = {})
    @@virtualbox = @@virtualbox.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@virtualbox.deep_merge(options))
  end

  def vagrant_configure
    super

    vagrant.name = vm.hostname
    vagrant.linked_clone = vm.options[:linked_clone]

    override.vm.network 'public_network'
  end
end

class Provisioner
  @@core = {
    'type' => '',
    'run' => '',
  }

  def self.core(options = {})
    @@core = @@core.deep_merge(options)
  end

  attr_reader :options
  attr_reader :vagrant
  attr_reader :vm

  def initialize(vm, options = {})
    @options = @@core.deep_merge(options)
    @vm = vm

    @vm.vagrant.vm.provision @options['type'], vagrant_options do |vagrant|
      @vagrant = vagrant

      vagrant_configure

      yield self if block_given?
    end
  end

  def vagrant_options
    {
      run: options['run'],
    }
  end

  def vagrant_configure
  end
end

class FileProvisioner < Provisioner
  @@file = {
    'type' => 'file',
    'source' => '',
    'destination' => '',
  }

  def self.file(options = {})
    @@file = @@file.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@file.deep_merge(options))
  end

  def vagrant_options
    super.deep_merge(source: options['source'], destination: options['destination'])
  end
end

class ShellProvisioner < Provisioner
  @@shell = {
    'type' => 'shell',
    'inline' => nil,
    'path' => nil,
  }

  def self.shell(options = {})
    @@shell = @@shell.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@shell.deep_merge(options))
  end

  def vagrant_options
    super.deep_merge(inline: options['inline'], path: options['path'])
  end
end

class ChefSoloProvisioner < Provisioner
  @@chef_solo = {
    'type' => 'chef_solo',
    'cookbooks_path' => [''],
    'run_list' => '',
    'json' => {},
  }

  def self.chef_solo(options = {})
    @@chef_solo = @@chef_solo.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@chef_solo.deep_merge(options))
  end

  def vagrant_configure
    super

    vagrant.cookbooks_path = options['cookbooks_path']
    vagrant.run_list = options['run_list'].split(',')
    vagrant.json = json(vm, options)
  end

  def json(vm, options)
    options['json']
  end
end

class DockerProvisioner < Provisioner
  @@docker = {
    'type' => 'docker',
    'builds' => [],
    'runs' => [],
  }

  def self.docker(options = {})
    @@docker = @@docker.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@docker.deep_merge(options))
  end

  def vagrant_configure
    super

    options['builds'].each do |build|
      vagrant.build_image build[:path], args: build[:args]
    end

    options['runs'].each do |run|
      vagrant.run run[:container],
        image: run[:image],
        args: run[:args],
        cmd: run[:cmd],
        restart: run[:restart]
    end
  end
end

class ::Hash
  def deep_merge(other)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
    self.merge(other.to_h, &merger)
  end
end
