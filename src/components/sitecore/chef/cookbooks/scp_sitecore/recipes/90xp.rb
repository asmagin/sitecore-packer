scp_sitecore_90xp '' do
  options node['scp_sitecore']['90xp']
  secrets node['scp_sitecore']['secrets']
  action :install
end