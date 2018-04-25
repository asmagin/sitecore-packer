property :options, Hash, required: true

default_action :install

action :install do
  scp_windows_chocolatey_packages '' do
    chocolatey_packages_options new_resource.options['chocolatey_packages_options']
  end

  powershell_script 'Enable Firewall' do
    code <<-EOH
     netsh advfirewall firewall add rule name="VS Remote Debugger" dir=in localport=#{new_resource.options['port']} protocol=TCP action=allow
    EOH
    action :run
  end

  # Setup autostart for debugger
  scripts_directory_path = 'c:/startup'
  startup_directory_path = 'c:/Users/vagrant/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup'

  directory scripts_directory_path do
    recursive true
    action :create
  end

  script_file_name = 'start-debugger.ps1'
  script_file_path = "#{scripts_directory_path}/#{script_file_name}"
  template script_file_path do
    source "#{script_file_name}.erb"
    variables(
      'port' => new_resource.options['port']
    )
  end

  cmd_file_name = 'start-debugger.startup.cmd'
  cmd_file_path = "#{startup_directory_path}/#{cmd_file_name}"
  template cmd_file_path do
    source "#{cmd_file_name}.erb"
    variables(
      'file_path' => script_file_path
    )
  end
end