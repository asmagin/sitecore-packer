scp_solr_server '' do
  server_options node['scp_solr']['solr721']
  action :prepare
end
