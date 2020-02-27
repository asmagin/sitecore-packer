property :options, Hash, required: true

action :install do
  scp_windows_chocolatey_packages '' do
    chocolatey_packages_options new_resource.options['chocolatey_packages_options']
  end
end

action :configure_firewall do
  # Open ports for remote debugging.
  # UDP 3702 - default port for discovery, can not be changed. https://docs.microsoft.com/en-us/visualstudio/debugger/remote-debugger-port-assignments?view=vs-2019#the-discovery-port
  powershell_script 'Configure Firewall for VS Remote Debugging' do
    code <<-EOH
      netsh advfirewall firewall add rule name="VS Remote Debugging TCP Inbound" dir=in action=allow protocol=TCP localport=#{new_resource.options['port_x64']}
      netsh advfirewall firewall add rule name="VS Remote Debugging TCP Inbound" dir=in action=allow protocol=TCP localport=#{new_resource.options['port_x86']}
      netsh advfirewall firewall add rule name="VS Remote Debugging UDP Inbound" dir=in action=allow protocol=UDP localport=3702
    EOH
    action :run
  end
end

action :configure_service_startuptype do
  powershell_script 'Run VS Remote Debugging /prepcomputer' do
    code <<-EOH
      Set-Service -Name msvsmon160 -StartupType Automatic
      Set-Service -Name VSStandardCollectorService150 -StartupType Automatic
    EOH
    action :run
  end
end

action :configure_msvsmon_logon_startup do
  # Setup autostart for remote debugger

  # Run VS Remote Debugging /prepcomputer
  powershell_script 'Run VS Remote Debugging /prepcomputer' do
    code <<-EOH
      Start-Process -FilePath '#{new_resource.options['msvsmon_path']}\\msvsmon.exe' -ArgumentList '/prepcomputer' -Verb runAs
    EOH
    action :run
  end

  scripts_directory_path = 'c:/startup'
  startup_directory_path = 'c:/Users/vagrant/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup'

  directory scripts_directory_path do
    recursive true
    action :create
  end

  script_file_name = 'start-debugger2019.ps1'
  script_file_path = "#{scripts_directory_path}/#{script_file_name}"
  template script_file_path do
    source "#{script_file_name}.erb"
    variables(
      'port' => new_resource.options['port_x64'],
      'msvsmon_path' => new_resource.options['msvsmon_path']
    )
  end

  cmd_file_name = 'start-debugger2019.startup.cmd'
  cmd_file_path = "#{startup_directory_path}/#{cmd_file_name}"
  template cmd_file_path do
    source "#{cmd_file_name}.erb"
    variables(
      'file_path' => script_file_path
    )
  end
end
