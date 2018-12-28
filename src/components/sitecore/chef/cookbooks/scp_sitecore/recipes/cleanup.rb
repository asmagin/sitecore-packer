scp_sitecore_license '' do
  action :cleanup_licenses
end

scp_sitecore_license '' do
  action :create_license_symlinks
end
