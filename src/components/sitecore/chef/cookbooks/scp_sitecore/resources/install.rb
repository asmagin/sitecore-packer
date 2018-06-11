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

  # Add sitecore root to trusted roots
  scp_windows_powershell_script_elevated 'Add certificates to cert:\LocalMachine\Root' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';

      Import-Certificate -CertStoreLocation cert:/LocalMachine/Root -FilePath #{sitecore['cert_path']}/SitecoreRootCert.cer
      Import-Certificate -CertStoreLocation cert:/LocalMachine/Root -FilePath #{sitecore['cert_path']}/SitecoreFundamentalsCert.cer
    EOH
    action :run
  end

  ## Install certificates for SSL
  scp_windows_powershell_script_elevated 'Add certificates to cert:\LocalMachine\Root' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';
      $pwd = ConvertTo-SecureString -String 'vagrant' -AsPlainText -Force

      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My -FilePath #{sitecore['cert_path']}/all.local.pfx -Password $pwd
      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My -FilePath #{sitecore['cert_path']}/all.sc9.local.pfx -Password $pwd
      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My -FilePath #{sitecore['cert_path']}/sc9.local_client.pfx -Password $pwd
      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My -FilePath #{sitecore['cert_path']}/sc9.xconnect_client.pfx -Password $pwd
    EOH
    action :run
  end

  # Copy license
  license_file_name = 'license.xml'
  license_file_path = "#{sitecore['root']}/#{license_file_name}"
  cookbook_file license_file_path do
    source license_file_name
    cookbook 'scp_sitecore'
    action :create
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

  # copy Sitecore PowerShell
  remote_directory sitecore['site_path'] do
    source 'spe'
    action :create
  end

  # Fix permissions
  directory "c:/inetpub/wwwroot/sc9.local" do
    rights :modify, 'BUILTIN\IIS_IUSRS'
  end

  directory "c:/inetpub/wwwroot/sc9.xconnect" do
    rights :modify, 'BUILTIN\IIS_IUSRS'
  end

  directory "C:/ProgramData/Microsoft/Crypto" do
    rights :modify, 'BUILTIN\IIS_IUSRS'
  end

  # Fix counters
  group 'Performance Monitor Users' do
    members ['IIS APPPOOL\sc9.local', 'IIS APPPOOL\sc9.xconnect', ]
    append true
    action :modify
  end

  # Confgure SSL certificate for sc90.local
  scp_windows_powershell_script_elevated 'Add bindings for wildcard subdomains' do
    code <<-EOH
      $subject = "#{sitecore['prefix']}.local"

      New-WebBinding -name $subject -Protocol http -HostHeader "*.local" -Port 80
      New-WebBinding -name $subject -Protocol http -HostHeader "*.$($subject)" -Port 80

      $guid = [guid]::NewGuid().ToString("B")

      # Add *.sc9.local bindings
      $cert = Get-ChildItem Cert:/LocalMachine/My | Where-Object { $_.Subject -eq "CN=*.$subject" }
      netsh http add sslcert hostnameport="*.$($subject):443" certhash="$($cert.Thumbprint)" certstorename=MY appid="$guid"
      New-WebBinding -name $subject -Protocol https  -HostHeader "*.$($subject)" -Port 443 -SslFlags 1

      # Add *.local bindings
      $cert = Get-ChildItem Cert:/LocalMachine/My | Where-Object { $_.Subject -eq "CN=*.local" }
      netsh http add sslcert hostnameport="*.local:443" certhash="$($cert.Thumbprint)" certstorename=MY appid="$guid"
      New-WebBinding -name $subject -Protocol https  -HostHeader "*.local" -Port 443 -SslFlags 1

      # Add *.azurewebsites.net bindings
      $cert = Get-ChildItem Cert:/LocalMachine/My | Where-Object { $_.Subject -eq "CN=*.local" }
      netsh http add sslcert hostnameport="*.azurewebsites.net:443" certhash="$($cert.Thumbprint)" certstorename=MY appid="$guid"
      New-WebBinding -name $subject -Protocol https  -HostHeader "*.azurewebsites.net" -Port 443 -SslFlags 1
      EOH
    action :run
  end
end