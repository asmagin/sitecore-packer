gusztavvargadr_windows_environment_variables '' do
  environment_variables_options node['gusztavvargadr_windows']['environment_variables']
  action :update
end
