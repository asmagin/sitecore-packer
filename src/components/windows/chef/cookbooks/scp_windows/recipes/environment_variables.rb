scp_windows_environment_variables '' do
  environment_variables_options node['scp_windows']['environment_variables']
  action :update
end
