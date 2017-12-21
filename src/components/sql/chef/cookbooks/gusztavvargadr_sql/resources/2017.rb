property :edition, String, name_property: true

action :install do
  directory_path = "#{Chef::Config[:file_cache_path]}/gusztavvargadr_sql/2017_#{edition}"

  directory directory_path do
    recursive true
    action :create
  end

  configuration_file_name = 'configuration.ini'
  configuration_file_path = "#{directory_path}/#{configuration_file_name}"
  configuration_file_source = '2017.ini'
  cookbook_file configuration_file_path do
    source configuration_file_source
    cookbook 'gusztavvargadr_sql'
    action :create
  end

  installer_iso_name = 'installer.iso'
  installer_iso_path = "#{directory_path}/#{installer_iso_name}"
  installer_iso_source = node['gusztavvargadr_sql']["2017_#{edition}"]['installer_iso_url']
  remote_file installer_iso_path do
    source installer_iso_source
    action :create
  end

  extracted_directory_path = 'I:/'
  gusztavvargadr_windows_iso installer_iso_path do
    iso_drive_letter 'I'
    action :mount
  end

  extracted_installer_file_name = 'SETUP.EXE'
  extracted_installer_file_path = "#{extracted_directory_path}/#{extracted_installer_file_name}"
  gusztavvargadr_windows_powershell_script_elevated "Install SQL Server 2017 #{edition}" do
    code <<-EOH
      Start-Process "#{extracted_installer_file_path.tr('/', '\\')}" "/CONFIGURATIONFILE=#{configuration_file_path.tr('/', '\\')} /IACCEPTSQLSERVERLICENSETERMS" -Wait
    EOH
    action :run
  end

  gusztavvargadr_windows_iso installer_iso_path do
    action :dismount
  end

  powershell_script 'Enable Firewall' do
    code <<-EOH
     netsh advfirewall firewall add rule name="SQL Server" dir=in localport=1433 protocol=TCP action=allow
    EOH
    action :run
  end
end
