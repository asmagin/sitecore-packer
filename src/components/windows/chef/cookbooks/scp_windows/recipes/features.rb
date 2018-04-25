scp_windows_features '' do
  features_options node['scp_windows']['features']
  action :install
end
