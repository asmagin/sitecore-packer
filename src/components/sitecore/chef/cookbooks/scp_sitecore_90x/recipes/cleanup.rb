scp_sitecore_90x_license '' do
  options node['scp_sitecore_90x']['install']
  action :cleanup_licenses
end

scp_sitecore_90x_license '' do
  options node['scp_sitecore_90x']['install']
  action :create_license_symlinks
end
