property :environment_variable_name, String, name_property: true
property :environment_variable_options, Hash, required: true

default_action :update

action :update do
  environment_variable_value = environment_variable_options['value']
  environment_variable_type = environment_variable_options['type'] || 'User'

  powershell_script "Update environment variable '#{environment_variable_name}'" do
    code <<-EOH
      [Environment]::SetEnvironmentVariable("#{environment_variable_name}", "#{environment_variable_value}", "#{environment_variable_type}")
    EOH
    action :run
  end
end
