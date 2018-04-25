property :files_options, Hash, required: true

default_action :create

action :create do
  files_options.each do |file_name, file_options|
    scp_windows_file file_name do
      file_options file_options ? file_options : {}
      action :create
    end
  end
end
