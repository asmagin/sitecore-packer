scp_windows_chocolatey_packages '' do
  chocolatey_packages_options node['scp_windows']['chocolatey_packages']
  action :install
end
