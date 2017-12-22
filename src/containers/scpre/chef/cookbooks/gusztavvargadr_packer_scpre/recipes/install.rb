include_recipe 'gusztavvargadr_packer_w::install'
include_recipe 'webpi::default'

gusztavvargadr_windows_chocolatey_packages '' do
  chocolatey_packages_options node['gusztavvargadr_packer_scpre']['default']['chocolatey_packages']
end

gusztavvargadr_windows_webpi_packages '' do
  packages_options node['gusztavvargadr_packer_scpre']['default']['webpi_packages']
end