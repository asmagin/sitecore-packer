property :native_package_name, String, name_property: true
property :native_package_options, Hash, required: true

default_action :install

action :install do
  native_package_source = native_package_options['source']
  native_package_install = native_package_options['install'].nil? ? {} : native_package_options['install']
  native_package_executable = native_package_options['executable']
  native_package_elevated = native_package_options['elevated']

  return if !native_package_executable.nil? && ::File.exist?(native_package_executable)

  native_package_download_directory_path = "#{Chef::Config[:file_cache_path]}/gusztavvargadr_windows"
  native_package_download_file_path = "#{native_package_download_directory_path}/#{native_package_name.tr(' ', '-')}.exe"

  gusztavvargadr_windows_file native_package_download_file_path do
    file_options('source' => native_package_source)
    action :create
  end

  native_package_script_name = "Install Native package '#{native_package_name}'"
  native_package_script_code = "Start-Process \"#{native_package_download_file_path.tr('/', '\\')}\" \"#{native_package_install.join(' ')}\" -Wait"

  if native_package_elevated
    gusztavvargadr_windows_powershell_script_elevated native_package_script_name do
      code native_package_script_code
      action :run
    end
  else
    powershell_script native_package_script_name do
      code native_package_script_code
      action :run
    end
  end
end
