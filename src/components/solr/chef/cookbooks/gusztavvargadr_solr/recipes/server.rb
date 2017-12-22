include_recipe 'nssm::default'

gusztavvargadr_solr_server '' do
  server_options node['gusztavvargadr_solr']['server']
  action :install
end
