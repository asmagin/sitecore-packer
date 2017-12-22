gusztavvargadr_solr_server '' do
  server_options node['gusztavvargadr_solr']['server']
  action :prepare
end
