scp_sitecore_93x_license '' do
  options node['scp_sitecore_93x']['common']
  action :cleanup_licenses
end

scp_sitecore_93x_license '' do
  options node['scp_sitecore_93x']['common']
  action :create_license_symlinks
end
