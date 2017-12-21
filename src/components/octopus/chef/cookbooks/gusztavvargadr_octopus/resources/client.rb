property :client_options, Hash, required: true

default_action :install

action :install do
  gusztavvargadr_windows_chocolatey_package 'octopustools' do
    chocolatey_package_options 'version' => client_options['version']
    action :install
  end
end
