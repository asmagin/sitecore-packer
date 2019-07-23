scp_sitecore_92x_license '' do
  options node['scp_sitecore_92x']['common']
  action :cleanup_licenses
end

scp_sitecore_92x_license '' do
  options node['scp_sitecore_92x']['common']
  action :create_license_symlinks
end
