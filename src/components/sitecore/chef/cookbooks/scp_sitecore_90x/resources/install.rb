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

  # Override config files
  remote_directory sitecore['root'] do
    source "configs/#{sitecore['version']}"
    action :create
  end

  # Copy certificates
  remote_directory sitecore['cert_path'] do
    source 'certificates'
    action :create
  end

  ## Install certificates for SSL
  scp_windows_powershell_script_elevated 'Install certificates for SSL' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';
      $pass = (ConvertTo-SecureString -String "#{sitecore['password']}" -Force -AsPlainText)
      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/Root -Password $pass -FilePath #{sitecore['cert_path']}/SitecoreRootCert.pfx
      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/CA   -Password $pass -FilePath #{sitecore['cert_path']}/SitecoreRootCert.pfx
      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath #{sitecore['cert_path']}/SitecoreRootCert.pfx
      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath #{sitecore['cert_path']}/sc9.xconnect.pfx
      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath #{sitecore['cert_path']}/sc9.local.pfx
    EOH
    action :run
  end

  # Copy license
  scp_sitecore_common_license '' do
    license_dir_path sitecore['root']
    license_filename 'license.xml'
    action :copy_license
  end

  # Generate install template
  script_file_name = 'install.ps1'
  script_file_path = "#{sitecore['root']}/#{script_file_name}"
  template script_file_path do
    source "install.ps1.#{sitecore['version']}.erb"
    variables('sitecore' => sitecore)
  end

  # Install Sitecore
  scp_windows_powershell_script_elevated 'Install Sitecore' do
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

  # Fix permissions
  directory sitecore['site_path'] do
    rights :modify, 'BUILTIN\IIS_IUSRS'
  end
  directory sitecore['xconnect_path'] do
    rights :modify, 'BUILTIN\IIS_IUSRS'
  end
  directory 'C:/ProgramData/Microsoft/Crypto' do
    rights :modify, 'BUILTIN\IIS_IUSRS'
  end

  # Fix counters
  group 'Performance Monitor Users' do
    members ["IIS APPPOOL\\#{sitecore['prefix']}.local", "IIS APPPOOL\\#{sitecore['prefix']}.xconnect"]
    append true
    action :modify
  end
end
