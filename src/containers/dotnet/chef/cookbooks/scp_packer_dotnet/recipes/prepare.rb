include_recipe 'scp_packer_w::prepare'

scp_windows_features '' do
  features_options node['scp_packer_dotnet']['default']['features']
end
