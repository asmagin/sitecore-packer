scp_sitecore_92x_install '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_92x']['common'], node['scp_sitecore_92x']['920xp'])
  secrets node['scp_sitecore_common']['secrets']
  action :install
end
