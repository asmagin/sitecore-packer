include_recipe 'nssm::default'

scp_solr_server '' do
  server_options node['scp_solr']['solr811']
  action :install
end
