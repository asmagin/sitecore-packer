property :options, Hash, required: true
property :secrets, Hash, required: true

default_action :install

# Install SC
action :install do
  # Install & update SIF
  user = new_resource.secrets['user']
  password = new_resource.secrets['password']

  sitecore = new_resource.options['sitecore']

  # Download Sitecore
  powershell_script 'Download Sitecore installation zip' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';

      if(-not(Test-Path "#{sitecore['package_full_path']}")) {
        $loginRequest = Invoke-RestMethod -Uri https://dev.sitecore.net/api/authorization -Method Post -ContentType "application/json" -Body "{username: '#{user}', password: '#{password}'}" -SessionVariable session -UseBasicParsing
        Invoke-WebRequest -Uri "#{sitecore['package_url']}" -WebSession $session -OutFile "#{sitecore['package_full_path']}" -UseBasicParsing
      }
    EOH
    action :run
  end

  # Extract archive
  powershell_script 'Unpack Sitecore' do
    code <<-EOH
      & 7z x "#{sitecore['package_full_path']}" -o"#{sitecore['root']}" -aoa
    EOH
    action :run
  end

  # Extract config files
  powershell_script 'Unpack config files' do
    code <<-EOH
      & 7z x "#{sitecore['package_config_path']}" -o"#{sitecore['root']}" -aoa
    EOH
    action :run
  end

  # Copy license
  license_file_name = 'license.xml'
  license_file_path = "#{sitecore['root']}/#{license_file_name}"
  cookbook_file license_file_path do
    source license_file_name
    cookbook 'gusztavvargadr_sitecore'
    action :create
  end

  # Generate install template
  script_file_name = 'install.ps1'
  script_file_path = "#{sitecore['root']}/#{script_file_name}"
  template script_file_path do
    source "#{sitecore['install_file_name']}.erb"
    variables('sitecore' => sitecore)
  end

  # Download Sitecore
  gusztavvargadr_windows_powershell_script_elevated 'Install Sitecore' do
    code script_file_path
    cwd sitecore['root']
    action :run
  end

  # remove Default Website
  iis_site 'Default Web Site' do
    action [:stop, :delete]
  end

  iis_pool 'DefaultAppPool' do
    action [:stop, :delete]
  end

  iis_site "#{sitecore['prefix']}.local" do
    bindings "http/*:80:#{sitecore['prefix']}.local,http/*:80:*.local"
    action [:config]
  end

  # Run post install script for xconnect
  script_file_name = 'xconnect-post-install.sql'
  script_file_path = "c:/tmp/#{script_file_name}"
  template script_file_path do
    source "#{script_file_name}.erb"
    variables('sitecore' => sitecore)
  end

  powershell_script 'Run post install script for xconnect' do
    code "Invoke-Sqlcmd -InputFile '#{script_file_path}' -ServerInstance 'localhost'"
    action :run
  end

  # copy Sitecore.Ship
  remote_directory sitecore['site_path'] do
    source 'ship'
    action :create
  end

  # copy Sitecore PowerShell
  remote_directory sitecore['site_path'] do
    source 'spe'
    action :create
  end

  # Fix permissions
  directory "c:/inetpub/wwwroot/sc90.local" do
    rights :modify, 'BUILTIN\IIS_IUSRS'
  end
  
  directory "c:/inetpub/wwwroot/sc90.xconnect" do
    rights :modify, 'BUILTIN\IIS_IUSRS'
  end
  
  directory "C:/ProgramData/Microsoft/Crypto " do
    rights :modify, 'BUILTIN\IIS_IUSRS'
  end
  
  # Fix counters
  group 'Performance Monitor Users' do
    members ['IIS APPPOOL\sc90.local', 'IIS APPPOOL\sc90.xconnect', ]
    append true
    action :modify
  end
end