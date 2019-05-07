scp_sitecore_91x_install '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_91x']['common'], node['scp_sitecore_91x']['911xp'])
  secrets node['scp_sitecore_91x']['secrets']
  action :install
end
