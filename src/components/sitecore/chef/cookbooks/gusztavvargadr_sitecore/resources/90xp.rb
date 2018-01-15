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
  powershell_script "Download Sitecore installation zip" do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';

      if(-not(Test-Path "#{sitecore['package_full_path']}")) {
        $loginRequest = Invoke-RestMethod -Uri https://dev.sitecore.net/api/authorization -Method Post -ContentType "application/json" -Body "{username: '#{user}', password: '#{password}'}" -SessionVariable session -UseBasicParsing
        Invoke-WebRequest -Uri "#{sitecore['url']}" -WebSession $session -OutFile "#{sitecore['package_full_path']}" -UseBasicParsing
      }
    EOH
    action :run
  end

  # Extract archive
  powershell_script "Unpack Sitecore" do
    code <<-EOH
      & 7z x "#{sitecore['package_full_path']}" -o"#{sitecore['root']}" -aoa
    EOH
    action :run
  end

  # Extract config files
  powershell_script "Unpack config files" do
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
    source "#{script_file_name}.erb"
    variables('sitecore' => sitecore)
  end

  # Download Sitecore
  gusztavvargadr_windows_powershell_script_elevated "Install Sitecore" do
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

  powershell_script "Run post install script for xconnect" do
    code "Invoke-Sqlcmd -InputFile '#{script_file_path}' -ServerInstance 'localhost'"
    action :run
  end

  # Fix permissions
  powershell_script "Fix permissions" do
    code <<-EOH
      $permission = 'BUILTIN\\IIS_IUSRS', 'Modify', 'Allow'
      $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
      $acl = Get-Acl 'C:/inetpub/wwwroot/sc90.local'
      $acl.SetAccessRule($accessRule)
      $acl | Set-Acl 'C:/inetpub/wwwroot/sc90.local'
    EOH
    action :run
  end
end