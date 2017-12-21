gusztavvargadr_octopus_tentacle '' do
  tentacle_options node['gusztavvargadr_octopus']['tentacle']
  action [:install, :configure]
end
