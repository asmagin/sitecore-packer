property :options, Hash, required: true
property :secrets, Hash, required: true

action :enable_contained_db_auth do
  # Enabled contained database authentication
  script_file_name = 'enable-containers.sql'
  script_file_path = "c:/tmp/#{script_file_name}"
  cookbook_file script_file_path do
    source script_file_name
    cookbook 'scp_sitecore_91x'
    action :create
  end

  powershell_script 'Enabled contained database authentication' do
    code "Invoke-Sqlcmd -InputFile '#{script_file_path}' -ServerInstance 'localhost'"
    action :run
  end
end

action :enable_mixed_auth do
  # Enabled mixed authentication
  script_file_name = 'enable-mixed-auth.sql'
  script_file_path = "c:/tmp/#{script_file_name}"
  cookbook_file script_file_path do
    source script_file_name
    cookbook 'scp_sitecore_91x'
    action :create
  end

  powershell_script 'Enabled mixed authentication' do
    code "Invoke-Sqlcmd -InputFile '#{script_file_path}' -ServerInstance 'localhost'"
    action :run
  end
end

action :enable_sa_login do
  # Enabled SA login
  script_file_name = 'enable-sa-login.sql'
  script_file_path = "c:/tmp/#{script_file_name}"
  template script_file_path do
    source "#{script_file_name}.erb"
    variables(
      password: new_resource.options['sql']['sa_password']
    )
  end

  powershell_script 'Enabled SA login' do
    code "Invoke-Sqlcmd -InputFile '#{script_file_path}' -ServerInstance 'localhost'"
    action :run
  end
end

action :enable_firewall do
  # Enable SBM and file sharing ports
  scp_windows_powershell_script_elevated 'Enable Firewall' do
    code <<-EOH
      netsh advfirewall firewall set rule name="File and Printer Sharing (NB-Session-In)" dir=in new enable=yes
      netsh advfirewall firewall set rule name="File and Printer Sharing (SMB-In)" dir=in new enable=yes
      netsh advfirewall firewall set rule name="File and Printer Sharing (Echo Request - ICMPv4-In)" dir=in new enable=yes
    EOH
    action :run
  end
end

action :install_and_update_sif do
  # Install & update SIF
  powershell_script 'Install & update SIF' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';
      Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2 -InstallationPolicy Trusted;
      Install-Module SitecoreInstallFramework -RequiredVersion #{new_resource.options['sitecore']['sif_version']} -Repository SitecoreGallery;
      Update-Module SitecoreInstallFramework -RequiredVersion #{new_resource.options['sitecore']['sif_version']};
    EOH
    action :run
  end
end

action :install_sitecore_prerequisites do
  sitecore = new_resource.options['sitecore']
  user = new_resource.secrets['user']
  password = new_resource.secrets['password']

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
    cookbook 'scp_sitecore_91x'
    action :create
  end

  # Install Sitecore Prerequisites
  scp_windows_powershell_script_elevated 'Install Sitecore Prerequisites' do
    code <<-EOH

    Install-SitecoreConfiguration -Path .\\prerequisites.json

    EOH
    cwd sitecore['root']
    action :run
  end
end
