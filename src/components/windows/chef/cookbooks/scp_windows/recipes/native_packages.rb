scp_windows_native_packages '' do
  native_packages_options node['scp_windows']['native_packages']
  action :install
end
