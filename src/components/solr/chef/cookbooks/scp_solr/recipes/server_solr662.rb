include_recipe 'nssm::default'

scp_solr_server '' do
  server_options node['scp_solr']['solr662']
  action :install
end
