scp_sitecore_90x_install '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_90x']['install'], node['scp_sitecore_90x']['901xp'])
  secrets node['scp_sitecore_common']['secrets']
  action :install
end
