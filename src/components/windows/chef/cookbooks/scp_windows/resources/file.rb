property :file_name, String, name_property: true
property :file_options, Hash, required: true

default_action :create

action :create do
  source_file_path = new_resource.file_options['source']
  return unless source_file_path

  target_file_path = new_resource.file_name
  target_directory_path = ::File.dirname(target_file_path)

  directory target_directory_path do
    recursive true
    action :create
  end

  remote_file target_file_path do
    source source_file_path
    action :create
  end
end
