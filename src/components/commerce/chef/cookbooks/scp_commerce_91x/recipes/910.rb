scp_commerce_91x_910 'Prepare for Sitecore Commerce installation' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce_91x']['common'], node['scp_commerce_91x']['910'])
  secrets node['scp_sitecore_common']['secrets']
  action :prepare
end

scp_commerce_91x_910 'Install Sitecore Commerce' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce_91x']['common'], node['scp_commerce_91x']['910'])
  install_storefront false
  action :install
end

scp_commerce_91x_910 'Post-installation Sitecore Commerce steps' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce_91x']['common'], node['scp_commerce_91x']['910'])
  action :postinstall
end
