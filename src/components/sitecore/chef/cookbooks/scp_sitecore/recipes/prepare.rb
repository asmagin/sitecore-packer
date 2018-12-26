include_recipe 'webpi::default'

scp_windows_chocolatey_packages '' do
  chocolatey_packages_options node['scp_sitecore']['prepare']['chocolatey_packages']
end

scp_windows_webpi_packages '' do
  packages_options node['scp_sitecore']['prepare']['webpi_packages']
end

scp_sitecore_prepare '' do
  options node['scp_sitecore']['prepare']
  action :enable_contained_db_auth
end

scp_sitecore_prepare '' do
  options node['scp_sitecore']['prepare']
  action :enable_mixed_auth
end

scp_sitecore_prepare '' do
  options node['scp_sitecore']['prepare']
  action :enable_sa_login
end

scp_sitecore_prepare '' do
  options node['scp_sitecore']['prepare']
  action :install_and_update_sif
end

scp_sitecore_prepare '' do
  options node['scp_sitecore']['prepare']
  action :enable_firewall
end
