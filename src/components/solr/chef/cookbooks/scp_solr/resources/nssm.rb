property :service_name, String, name_property: true
property :service_options, Hash, required: true

default_action :install

action :install do
  nssm new_resource.service_name do
    program new_resource.service_options['program']
    args new_resource.service_options['args']
    parameters new_resource.service_options['parameters']
    action [:install, :start]
  end
end
