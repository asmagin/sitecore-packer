scp_iis_server '' do
  server_options node['scp_iis']['server']
  action :install
end
