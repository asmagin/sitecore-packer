scp_sitecore_91x_prepare '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_91x']['common'], node['scp_sitecore_91x']['911xp'])
  secrets node['scp_sitecore_91x']['secrets']
  action :enable_contained_db_auth
end

scp_sitecore_91x_prepare '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_91x']['common'], node['scp_sitecore_91x']['911xp'])
  secrets node['scp_sitecore_91x']['secrets']
  action :enable_mixed_auth
end

scp_sitecore_91x_prepare '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_91x']['common'], node['scp_sitecore_91x']['911xp'])
  secrets node['scp_sitecore_91x']['secrets']
  action :enable_sa_login
end

scp_sitecore_91x_prepare '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_91x']['common'], node['scp_sitecore_91x']['911xp'])
  secrets node['scp_sitecore_91x']['secrets']
  action :enable_firewall
end

scp_sitecore_91x_prepare '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_91x']['common'], node['scp_sitecore_91x']['911xp'])
  secrets node['scp_sitecore_91x']['secrets']
  action :install_and_update_sif
end

scp_sitecore_91x_prepare '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_91x']['common'], node['scp_sitecore_91x']['911xp'])
  secrets node['scp_sitecore_91x']['secrets']
  action :install_sitecore_prerequisites
end
