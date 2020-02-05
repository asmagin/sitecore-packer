scp_sitecore_93x_install '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_93x']['common'], node['scp_sitecore_93x']['930xp'])
  secrets node['scp_sitecore_common']['secrets']
  action :install
end
