scp_sitecore_install '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore']['install'], node['scp_sitecore']['901xp'])
  secrets node['scp_sitecore']['secrets']
  action :install
end
