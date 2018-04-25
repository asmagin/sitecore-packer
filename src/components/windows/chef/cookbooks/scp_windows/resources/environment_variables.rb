property :environment_variables_options, Hash, required: true

default_action :update

action :update do
  environment_variables_options.each do |environment_variable_name, environment_variable_options|
    scp_windows_environment_variable environment_variable_name do
      environment_variable_options environment_variable_options || {}
      action :update
    end
  end
end
