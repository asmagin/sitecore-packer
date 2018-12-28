# Install Sitecore JavaScript Services
scp_sitecore_modules_install_jss 'Install Sitecore JavaScript Services' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common'], node['scp_sitecore_modules']['jss'])
  secrets node['scp_sitecore_modules']['secrets']
  action :install
end
