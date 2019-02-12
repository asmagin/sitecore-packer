# Install Sitecore Powershell Extentions Remoting Powershell Module
scp_sitecore_modules_install_spe_remoting 'Install Sitecore Powershell Extentions Remoting Powershell Module' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common'], node['scp_sitecore_modules']['spe_remoting'])
  action :install
end

# Install Sitecore Experience Accelerator
scp_sitecore_modules_install_sxa 'Install Sitecore Experience Accelerator' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common'], node['scp_sitecore_modules']['sxa_180'])
  secrets node['scp_sitecore_modules']['secrets']
  action :install
end

# Add SOLR cores for Sitecore Experience Accelerator
scp_sitecore_modules_install_sxa 'Add SOLR cores for Sitecore Experience Accelerator' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common'], node['scp_sitecore_modules']['sxa_180'])
  secrets node['scp_sitecore_modules']['secrets']
  action :add_sxa_solr_cores
end
