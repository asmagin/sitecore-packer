scp_commerce_901 '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce']['install'], node['scp_commerce']['901'])
  secrets node['scp_sitecore_common']['secrets']
  action :install
end
