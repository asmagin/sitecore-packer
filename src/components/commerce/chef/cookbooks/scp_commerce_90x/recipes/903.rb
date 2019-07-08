scp_commerce_90x_903 'Prepare for Sitecore Commerce installation' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce_90x']['common'], node['scp_commerce_90x']['903'])
  secrets node['scp_sitecore_common']['secrets']
  action :prepare
end

scp_commerce_90x_903 'Install Sitecore Commerce' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce_90x']['common'], node['scp_commerce_90x']['903'])
  install_storefront false
  action :install
end
