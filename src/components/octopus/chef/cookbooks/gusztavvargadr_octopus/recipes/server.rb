gusztavvargadr_octopus_server 'Server' do
  server_options node['gusztavvargadr_octopus']['server']
  action [:install, :configure, :import]
end
