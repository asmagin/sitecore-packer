scp_solr_server '' do
  server_options node['scp_solr']['server']
  action :prepare
end
