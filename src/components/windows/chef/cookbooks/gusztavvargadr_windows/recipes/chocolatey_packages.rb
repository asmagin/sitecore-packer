gusztavvargadr_windows_chocolatey_packages '' do
  chocolatey_packages_options node['gusztavvargadr_windows']['chocolatey_packages']
  action :install
end
