scp_sitecore_91x_license '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_91x']['common'], node['scp_sitecore_91x']['910xp'])
  action :cleanup_licenses
end

scp_sitecore_91x_license '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_91x']['common'], node['scp_sitecore_91x']['910xp'])
  action :create_license_symlinks
end
