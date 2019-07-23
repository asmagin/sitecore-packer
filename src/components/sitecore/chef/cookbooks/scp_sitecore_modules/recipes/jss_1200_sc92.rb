# Install NodeJS LTS
scp_sitecore_modules_install_nodejs_lts 'Install NodeJS LTS' do
end

# Install Sitecore JavaScript Services
scp_sitecore_modules_install_jss 'Install Sitecore JavaScript Services' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_sitecore_modules']['common_sc92'], node['scp_sitecore_modules']['jss_1200_sc92'])
  secrets node['scp_sitecore_common']['secrets']
  action :install
end
