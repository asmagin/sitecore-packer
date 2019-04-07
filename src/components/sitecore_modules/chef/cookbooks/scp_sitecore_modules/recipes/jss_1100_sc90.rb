# Install Sitecore JavaScript Services
scp_sitecore_modules_install_jss 'Install Sitecore JavaScript Services' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common'], node['scp_sitecore_modules']['jss_1100_sc90'])
  secrets node['scp_sitecore_modules']['secrets']
  action :install
end

# Fix web.config Newtonsoft.Json oldVersion attribute. Applicable only for 9.0.X Sitecore versions (no need for 9.1)
scp_sitecore_modules_install_jss 'Fix web.config Newtonsoft.Json oldVersion attribute' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common'], node['scp_sitecore_modules']['jss_1100_sc90'])
  secrets node['scp_sitecore_modules']['secrets']
  action :fix_web_config_for_90
end
