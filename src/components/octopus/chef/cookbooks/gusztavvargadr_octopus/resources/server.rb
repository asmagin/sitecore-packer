property :server_instance_name, String, name_property: true
property :server_options, Hash, required: true

default_action :install

action :install do
  gusztavvargadr_windows_chocolatey_package 'octopusdeploy' do
    chocolatey_package_options 'version' => server_options['version']
    action :install
  end
end

action :configure do
  server_instance_name = 'Server' if server_instance_name.to_s.empty?
  server_execute_username = server_options['execute_username']
  server_execute_password = server_options['execute_password']
  server_home_directory_path = server_options['home_directory_path']
  server_service_username = server_options['service_username']
  server_storage_connection_string = server_options['storage_connection_string']
  server_web_addresses = server_options['web_addresses']
  server_web_username = server_options['web_username']
  server_web_password = server_options['web_password']
  server_communication_port = server_options['communication_port']
  server_node_name = server_options['node_name']
  server_license = server_options['license']

  return if server_web_username.to_s.empty?
  return if ::File.exist?("#{server_home_directory_path}\\#{server_instance_name}.config")

  server_executable_file_path = 'C:\\Program Files\\Octopus Deploy\\Octopus\\Octopus.Server.exe'
  gusztavvargadr_windows_powershell_script_elevated "Configure '#{server_instance_name}'" do
    code <<-EOH
      & "#{server_executable_file_path}" create-instance --instance "#{server_instance_name}" --config "#{server_home_directory_path}\\#{server_instance_name}.config" --console
      & "#{server_executable_file_path}" configure --instance "#{server_instance_name}" --home "#{server_home_directory_path}" --storageConnectionString "#{server_storage_connection_string}" --upgradeCheck "False" --upgradeCheckWithStatistics "False" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "#{server_web_addresses.join(',')}" --commsListenPort "#{server_communication_port}" --serverNodeName "#{server_node_name}" --console
      & "#{server_executable_file_path}" database --instance "#{server_instance_name}" --create --grant "#{server_service_username}" --console
      & "#{server_executable_file_path}" service --instance "#{server_instance_name}" --stop --console
      & "#{server_executable_file_path}" admin --instance "#{server_instance_name}" --username "#{server_web_username}" --password "#{server_web_password}" --console
      #{unless server_license.to_s.empty?
          "& \"#{server_executable_file_path}\" license --instance \"#{server_instance_name}\" --licenseBase64 \"#{server_license}\" --console"
        end}
      & "#{server_executable_file_path}" service --instance "#{server_instance_name}" --install --reconfigure --start --console
    EOH
    user server_execute_username
    password server_execute_password
    action :run
  end

  server_web_addresses.each do |server_web_address|
    web_port = URI(server_web_address).port
    powershell_script "Enable '#{server_instance_name}' web port '#{web_port}'" do
      code <<-EOH
        netsh advfirewall firewall add rule "name=Octopus Server '#{server_instance_name}' Web" dir=in action=allow protocol=TCP localport=#{web_port}
      EOH
      action :run
    end
  end

  powershell_script "Enable '#{server_instance_name}' communication port '#{server_communication_port}'" do
    code <<-EOH
      netsh advfirewall firewall add rule "name=Octopus Server '#{server_instance_name}' Communication" dir=in action=allow protocol=TCP localport=#{server_communication_port}
    EOH
    action :run
  end
end

action :import do
  server_instance_name = 'Server' if server_instance_name.to_s.empty?
  server_execute_username = server_options['execute_username']
  server_execute_password = server_options['execute_password']
  server_import = server_options['import']

  return if server_import.nil?

  server_import.each do |server_import_location, server_import_options|
    next if server_import_location.to_s.empty?

    server_import_cookbook = server_import_location.split('::')[0]
    server_import_source = server_import_location.split('::')[1]

    server_import_directory_path = "#{Chef::Config[:file_cache_path]}/gusztavvargadr_octopus/server/import/#{server_import_source}"
    remote_directory server_import_directory_path do
      source server_import_source
      cookbook server_import_cookbook
      action :create
    end

    server_executable_directory_path = 'C:\\Program Files\\Octopus Deploy\\Octopus'
    gusztavvargadr_windows_powershell_script_elevated "Import '#{server_instance_name}' from '#{server_import_directory_path}'" do
      code <<-EOH
        & "#{server_executable_directory_path}\\Octopus.Migrator.exe" import --instance "#{server_instance_name}" --directory "#{server_import_directory_path}" --password "#{server_import_options['password']}" --overwrite --console
        & "#{server_executable_directory_path}\\Octopus.Server.exe" service --instance "#{server_instance_name}" --stop --start --console
      EOH
      user server_execute_username
      password server_execute_password
      action :run
    end
  end
end
