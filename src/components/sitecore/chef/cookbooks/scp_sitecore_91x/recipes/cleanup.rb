scp_sitecore_91x_license '' do
  options node['scp_sitecore_91x']['common']
  action :cleanup_licenses
end

scp_sitecore_91x_license '' do
  options node['scp_sitecore_91x']['common']
  action :create_license_symlinks
end
