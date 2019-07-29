scp_commerce_902 '' do
  options Chef::Mixin::DeepMerge.deep_merge(node['scp_commerce']['install'], node['scp_commerce']['902'])
  secrets node['scp_commerce']['secrets']
  action :install
end
