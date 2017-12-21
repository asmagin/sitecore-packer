include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_windows_chocolatey_packages '' do
  chocolatey_packages_options node['gusztavvargadr_packer_scsolr']['default']['chocolatey_packages']
end