property :options, Hash, required: true
property :secrets, Hash, required: true

default_action :install

# Install Sitecore JavaScript Services
action :install do
  config = new_resource.options['config']

  # Ensure directory exists
  scripts_directory_path = config['root'].to_s
  directory scripts_directory_path do
    recursive true
    action :create
  end

  scp_sitecore_modules_install_module 'Install Sitecore JavaScript Services' do
    options new_resource.options
    secrets new_resource.secrets
    action :install
  end

  # Fix web.config Newtonsoft.Json oldVersion attribute. Applicable only for 9.0.X Sitecore versions (no need for 9.1)
  scp_sitecore_modules_set_xml_attribute 'Fix web.config Newtonsoft.Json oldVersion attribute' do
    path "#{config['site_path']}/Web.config"
    xpath '//ns:assemblyIdentity[@name="Newtonsoft.Json"]/../ns:bindingRedirect/@oldVersion'
    value '0.0.0.0-11.0.0.0'
    namespace 'urn:schemas-microsoft-com:asm.v1'
  end
end
