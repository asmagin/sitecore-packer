property :options, Hash, required: true
property :secrets, Hash, required: true

default_action :install

# Install Sitecore Powershell Extentions
action :install do
  config = new_resource.options['config']

  # Ensure directory exists
  scripts_directory_path = config['root'].to_s
  directory scripts_directory_path do
    recursive true
    action :create
  end

  # Install Sitecore Powershell Extentions
  scp_sitecore_modules_install_module 'Install Sitecore Powershell Extentions' do
    options new_resource.options
    secrets new_resource.secrets
    action :install
  end
end
