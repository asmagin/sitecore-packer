property :options, Hash, required: true
property :secrets, Hash, required: true

default_action :install

# Install SC
action :install do
  # Install & update SIF
  user = new_resource.secrets['user']
  password = new_resource.secrets['password']

  sitecore = new_resource.options['sitecore']

  # Download Sitecore Commerce
  ## Download Commerce packages (to c:\tmp)
  powershell_script 'Download Sitecore Commerce Package' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';

      if(-not(Test-Path "#{sitecore['package_zip_path']}")) {
        $loginRequest = Invoke-RestMethod -Uri https://dev.sitecore.net/api/authorization -Method Post -ContentType "application/json" -Body "{username: '#{user}', password: '#{password}'}" -SessionVariable session -UseBasicParsing
        Invoke-WebRequest -Uri "#{sitecore['package_url']}" -WebSession $session -OutFile "#{sitecore['package_zip_path']}" -UseBasicParsing
      }
    EOH
    action :run
  end

  ## Extract Commerce Package (to c:\tmp\sitecore)
  powershell_script 'Unpack Sitecore Commerce Package' do
    code <<-EOH
      & 7z x "#{sitecore['package_zip_path']}" -o"#{sitecore['root']}" -aoa
    EOH
    action :run
  end

  ## Download SXA (to c:\tmp\sitecore)
  powershell_script 'Download SXA' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';

      if(-not(Test-Path "#{sitecore['package_sxa_zip_path']}")) {
        $loginRequest = Invoke-RestMethod -Uri https://dev.sitecore.net/api/authorization -Method Post -ContentType "application/json" -Body "{username: '#{user}', password: '#{password}'}" -SessionVariable session -UseBasicParsing
        Invoke-WebRequest -Uri "#{sitecore['package_sxa_url']}" -WebSession $session -OutFile "#{sitecore['package_sxa_zip_path']}" -UseBasicParsing
      }
    EOH
    action :run
  end

  ## Download SPE (to c:\tmp\sitecore)
  powershell_script 'Download SPE' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';

      if(-not(Test-Path "#{sitecore['package_spe_zip_path']}")) {
        Invoke-WebRequest -Uri "#{sitecore['package_spe_url']}" -WebSession $session -OutFile "#{sitecore['package_spe_zip_path']}" -UseBasicParsing
      }
    EOH
    action :run
  end

  ## Download NuGet (to c:\tmp\sitecore)
  powershell_script 'Download [MSBuild.Microsoft.VisualStudio.Web.targets] Nuget' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';

      if(-not(Test-Path "#{sitecore['package_nuget_zip_path']}")) {
        Invoke-WebRequest -Uri "#{sitecore['package_nuget_url']}" -WebSession $session -OutFile "#{sitecore['package_nuget_zip_path']}" -UseBasicParsing
      }
    EOH
    action :run
  end

  ## Exctract NuGet files (to c:\tmp\sitecore)
  powershell_script 'Unpack [MSBuild.Microsoft.VisualStudio.Web.targets] Nuget' do
    code <<-EOH
      & 7z x "#{sitecore['package_nuget_zip_path']}" -o"#{sitecore['package_nuget_path']}/" -aoa
    EOH
    action :run
  end

  ## Extract SIF.Sitecore.Commerce (to c:\tmp\sitecore\sif ?)
  powershell_script 'Unpack SIF.Sitecore.Commerce files' do
    code <<-EOH
      & 7z x "#{sitecore['package_config_zip_path']}" -o"#{sitecore['package_config_path']}" -aoa
    EOH
    action :run
  end

  ## Extract Sitecore.BizFX
  powershell_script 'Unpack Sitecore.BizFX files' do
    code <<-EOH
      & 7z x "#{sitecore['package_bizfx_zip_path']}" -o"#{sitecore['package_bizfx_path']}" -aoa
    EOH
    action :run
  end

  ## Extract Sitecore.Commerce.Engine.SDK
  powershell_script 'Unpack Sitecore.Commerce.Engine.SDK files' do
    code <<-EOH
      & 7z x "#{sitecore['package_sdk_zip_path']}" -o"#{sitecore['package_sdk_path']}" -aoa
    EOH
    action :run
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

      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath #{sitecore['cert_path']}/sc9.commerce.pfx
    EOH
    action :run
  end

  # Install Commerce
  ## Stop xConnect
  iis_pool "#{sitecore['prefix']}.xconnect" do
    action [:stop]
  end

  ## Generate installation script from template
  script_file_name = 'install.ps1'
  script_file_path = "#{sitecore['package_config_path']}/#{script_file_name}"
  template script_file_path do
    source "install.#{sitecore['version']}.ps1.erb"
    variables('sitecore' => sitecore)
  end

  ## Override configuration files and SIF modules
  remote_directory sitecore['package_config_path'] do
    source "sif/#{sitecore['version']}"
    action :create
  end

  ## Run installation scripts
  scp_windows_powershell_script_elevated 'Install Sitecore' do
    code script_file_path
    cwd sitecore['package_config_path']
    action :run
  end

  ## Start xConnect
  iis_pool "#{sitecore['prefix']}.xconnect" do
    action [:start]
  end

  # Open required ports
  powershell_script 'Enable ports for Commerce' do
    code <<-EOH
      netsh advfirewall firewall add rule name="SC Commerce Biz" dir=in localport=#{sitecore['port_biz']} protocol=TCP action=allow
      netsh advfirewall firewall add rule name="SC Commerce Ops" dir=in localport=#{sitecore['port_ops']} protocol=TCP action=allow
    EOH
    action :run
  end
end