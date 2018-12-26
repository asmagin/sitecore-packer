property :options, Hash, required: true
property :secrets, Hash, required: true

default_action :install

action :install do
  config = new_resource.options['config']

  user = new_resource.secrets['user']
  password = new_resource.secrets['password']

  # Pre install script
  script_file_name = 'drop-users-and-set-containment.sql'
  script_file_path = "#{config['root']}/#{script_file_name}"
  template script_file_path do
    source "#{script_file_name}.erb"
    variables('config' => config)
  end

  powershell_script 'Run pre install script' do
    code "Invoke-Sqlcmd -InputFile '#{script_file_path}' -ServerInstance 'localhost'"
    action :run
  end

  # Download module
  powershell_script "Download #{config['package_original_name']}" do
    code <<-EOH

      $ProgressPreference='SilentlyContinue';

      if(-not(Test-Path "#{config['package_full_path']}")) {
        $loginRequest = Invoke-RestMethod -Uri https://dev.sitecore.net/api/authorization -Method Post -ContentType "application/json" -Body "{username: '#{user}', password: '#{password}'}" -SessionVariable session -UseBasicParsing
        Invoke-WebRequest -Uri "#{config['package_url']}" -WebSession $session -OutFile "#{config['package_full_path']}" -UseBasicParsing
      }

    EOH
    action :run
    timeout 600
  end

  # Generate install template
  script_file_name = "install_sitecore_#{config['module']}.ps1"
  script_file_path = "#{config['root']}/#{script_file_name}"
  template script_file_path do
    source 'install_module.ps1.erb'
    variables('config' => config)
  end

  # Install module
  powershell_script "Install #{config['package_original_name']}" do
    code script_file_path
    cwd config['root']
    timeout 600
    action :run
  end

  # Post install script
  script_file_name = 'add-users-and-set-containment.sql'
  script_file_path = "#{config['root']}/#{script_file_name}"
  template script_file_path do
    source "#{script_file_name}.erb"
    variables('config' => config)
  end

  powershell_script 'Run post install script' do
    code "Invoke-Sqlcmd -InputFile '#{script_file_path}' -ServerInstance 'localhost'"
    action :run
  end
end
