include_recipe 'scp_packer_w::install'

scp_windows_native_packages '' do
  native_packages_options node['scp_packer_dotnet']['default']['native_packages']
end
