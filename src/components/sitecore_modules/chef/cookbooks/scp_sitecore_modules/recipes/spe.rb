# Install Sitecore Powershell Extentions
scp_sitecore_modules_install_spe 'Install Sitecore Powershell Extentions' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common'], node['scp_sitecore_modules']['spe'])
  secrets node['scp_sitecore_modules']['secrets']
  action :install
end
