# Install Sitecore Azure Toolkit
scp_sitecore_modules_install_azuretoolkit 'Install Sitecore Azure Toolkit' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common'], node['scp_sitecore_modules']['azuretoolkit'])
  secrets node['scp_sitecore_modules']['secrets']
  action :install
end
