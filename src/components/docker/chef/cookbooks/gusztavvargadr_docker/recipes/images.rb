gusztavvargadr_docker_images '' do
  images_options node['gusztavvargadr_docker']['images']
  action :pull
end
