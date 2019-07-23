# Install Sitecore Experience Accelerator
scp_sitecore_modules_install_sxa 'Install Sitecore Experience Accelerator' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common_sc92'], node['scp_sitecore_modules']['sxa_190_sc92'])
  secrets node['scp_sitecore_common']['secrets']
  action :install
end

# Add SOLR cores for Sitecore Experience Accelerator
scp_sitecore_modules_install_sxa 'Add SOLR cores for Sitecore Experience Accelerator' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common_sc92'], node['scp_sitecore_modules']['sxa_190_sc92'])
  secrets node['scp_sitecore_common']['secrets']
  action :add_sxa_solr_cores
end
