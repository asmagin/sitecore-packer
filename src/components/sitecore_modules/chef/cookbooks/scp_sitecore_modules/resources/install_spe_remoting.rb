property :options, Hash, required: true

default_action :install

action :install do
  config = new_resource.options['config']

  # Ensure directory exists
  scripts_directory_path = config['root'].to_s
  directory scripts_directory_path do
    recursive true
    action :create
  end

  # Install Sitecore Powershell Extentions Remoting Powershell Module
  scp_sitecore_modules_install_ps_module 'Install Sitecore Powershell Extentions Remoting Powershell Module' do
    package_full_path config['package_full_path']
    package_url config['package_url']
    action :install
  end
end
