property :package_name, String, name_property: true
property :package_options, Hash, required: true

default_action :install

action :install do
  webpi_product package_name do
    accept_eula package_options['accept_eula']
    action :install
  end
end
