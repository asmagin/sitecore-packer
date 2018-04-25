scp_windows_files '' do
  files_options node['scp_windows']['files']
  action :create
end
