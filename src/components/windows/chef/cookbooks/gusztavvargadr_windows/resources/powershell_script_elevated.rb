property :command, String, name_property: true
property :user, String, default: ''
property :password, String, default: ''
property :cwd, String, default: 'C:\\'
property :code, String, required: true
property :wait_poll, Integer, default: 5
property :timeout, Integer, default: 3600

default_action :run

action :run do
  script_name = "powershell-script-elevated-#{Time.now.to_i}"

  script_directory_path = "#{Chef::Config[:file_cache_path].tr('/', '\\')}\\gusztavvargadr_windows"
  directory script_directory_path do
    recursive true
    action :create
  end

  script_file_path = "#{script_directory_path}\\#{script_name}.ps1"
  script_log_path = "#{script_directory_path}\\#{script_name}.log"
  file script_file_path do
    content <<-EOH
      # #{command}
      $(
        #{code}
      ) *>&1 > #{script_log_path}
    EOH
    action :create
  end

  windows_task_name = script_name
  windows_task_command = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -NoProfile -ExecutionPolicy Bypass -File '#{script_file_path}'"

  if new_resource.user.to_s.empty?
    windows_task windows_task_name do
      cwd new_resource.cwd
      command windows_task_command
      frequency :once
      start_time '00:00'
      action [:create, :run]
      run_level :highest
    end
  else
    windows_task windows_task_name do
      user new_resource.user
      password new_resource.password
      cwd new_resource.cwd
      command windows_task_command
      frequency :once
      start_time '00:00'
      action [:create, :run]
      run_level :highest
    end
  end

  powershell_script "Wait for task '#{windows_task_name}'" do
    code <<-EOH
      while ((Get-ScheduledTask -TaskName "#{windows_task_name}").State -ne "Ready")
      {
        Start-Sleep #{wait_poll}
      }
    EOH
    timeout new_resource.timeout
    action :run
  end

  windows_task windows_task_name do
    action :delete
  end
end
