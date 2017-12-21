gusztavvargadr_iis_server '' do
  server_options node['gusztavvargadr_iis']['server']
  action :install
end
