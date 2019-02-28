scp_solr_server '' do
  server_options node['scp_solr']['solr662']
  action :prepare
end
