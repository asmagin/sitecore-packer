property :service_name, String, name_property: true
property :service_options, Hash, required: true

default_action :install

action :install do
  nssm service_name do
    program service_options['program']
    args service_options['args']
    parameters service_options['parameters']
    action [:install, :start]
  end
end
