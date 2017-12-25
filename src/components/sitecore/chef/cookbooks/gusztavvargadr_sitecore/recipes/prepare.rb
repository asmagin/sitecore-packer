include_recipe 'webpi::default'

gusztavvargadr_windows_chocolatey_packages '' do
  chocolatey_packages_options node['gusztavvargadr_sitecore']['prepare']['chocolatey_packages']
end

gusztavvargadr_windows_webpi_packages '' do
  packages_options node['gusztavvargadr_sitecore']['prepare']['webpi_packages']
end

gusztavvargadr_sitecore_prepare '' do
  options node['gusztavvargadr_sitecore']['prepare']
  action :enable_contained_db_auth
end

gusztavvargadr_sitecore_prepare '' do
  options node['gusztavvargadr_sitecore']['prepare']
  action :enable_mixed_auth
end

gusztavvargadr_sitecore_prepare '' do
  options node['gusztavvargadr_sitecore']['prepare']
  action :enable_sa_login
end

gusztavvargadr_sitecore_prepare '' do
  options node['gusztavvargadr_sitecore']['prepare']
  action :install_and_update_sif
end
