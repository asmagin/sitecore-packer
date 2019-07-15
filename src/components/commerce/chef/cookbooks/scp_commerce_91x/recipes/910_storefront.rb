scp_commerce_91x_910 'Prepare for Sitecore Commerce installation' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce_91x']['common'], node['scp_commerce_91x']['910'])
  secrets node['scp_sitecore_common']['secrets']
  action :prepare
end

scp_commerce_91x_910 'Install Sitecore Commerce' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce_91x']['common'], node['scp_commerce_91x']['910'])
  install_storefront true
  action :install
end

scp_commerce_91x_910 'Post-installation Sitecore Commerce steps' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce_91x']['common'], node['scp_commerce_91x']['910'])
  action :postinstall
end

scp_sitecore_modules_install_sxa 'Add SOLR cores for Sitecore Experience Accelerator' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common'], node['scp_sitecore_modules']['sxa_181_sc91'])
  secrets node['scp_sitecore_common']['secrets']
  action :add_sxa_solr_cores
end

scp_commerce_91x_910 'Fix Storefront installation' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce_91x']['common'], node['scp_commerce_91x']['910'])
  action :fix_storefront
end
