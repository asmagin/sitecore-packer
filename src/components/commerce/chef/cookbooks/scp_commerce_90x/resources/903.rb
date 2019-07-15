property :options, Hash, required: true
property :secrets, Hash
property :install_storefront, [true, false], default: false

# Prepare for installation
action :prepare do
  secrets = new_resource.secrets
  install = new_resource.options['install']
  sitecore = new_resource.options['sitecore']
  commerce = new_resource.options['commerce']

  ## Download and extract - Sitecore Commerce 9.1.0
  scp_sitecore_common_download_sitecore_package 'Sitecore Commerce 9.0.3' do
    package_url install['commerce_package_url']
    package_path install['commerce_package_zip_path']
    user secrets['user']
    password secrets['password']
  end
  scp_sitecore_common_unzip 'Sitecore Commerce 9.0.3' do
    source install['commerce_package_zip_path']
    destination install['root']
  end

  ## Download, extract and delete archive - MSBuild.Microsoft.VisualStudio.Web.targets
  scp_sitecore_common_download_package 'MSBuild.Microsoft.VisualStudio.Web.targets' do
    package_url install['msvs_web_targets_nuget_url']
    package_path install['msvs_web_targets_nuget_path']
  end
  scp_sitecore_common_unzip 'MSBuild.Microsoft.VisualStudio.Web.targets' do
    source install['msvs_web_targets_nuget_path']
    destination install['msvs_web_targets_content_path']
  end
  file install['msvs_web_targets_nuget_path'] do
    action :delete
  end

  ## Extract and delete - SIF.Sitecore.Commerce
  scp_sitecore_common_unzip 'SIF.Sitecore.Commerce' do
    source install['commerce_sif_zip_path']
    destination install['commerce_sif_content_path']
  end
  file install['commerce_sif_zip_path'] do
    action :delete
  end

  ## Extract and delete - Sitecore.BizFX
  scp_sitecore_common_unzip 'Sitecore.BizFX' do
    source install['commerce_bizfx_zip_path']
    destination install['commerce_bizfx_content_path']
  end
  file install['commerce_bizfx_zip_path'] do
    action :delete
  end

  ## Extract and delete - Sitecore.Commerce.Engine.SDK
  scp_sitecore_common_unzip 'Sitecore.Commerce.Engine.SDK' do
    source install['commerce_engine_sdk_zip_path']
    destination install['commerce_engine_sdk_content_path']
  end
  file install['commerce_engine_sdk_zip_path'] do
    action :delete
  end

  # Copy certificates
  remote_directory install['cert_path'] do
    source 'certificates'
    action :create
  end

  ## Install certificates for SSL
  scp_windows_powershell_script_elevated 'Install certificates for SSL' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';
      $pass = (ConvertTo-SecureString -String "#{install['windows_user_password']}" -Force -AsPlainText)
      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My -Password $pass -FilePath #{install['cert_path']}/localhost.pfx
      Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My -Password $pass -FilePath #{install['cert_path']}/#{commerce['storefront_hostname']}.pfx
    EOH
    action :run
  end

  ## Clear windows components cache (caused issues)
  scp_windows_powershell_script_elevated 'Clear windows components cache' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';
      Remove-Item -Path "Registry::HKLM\\SOFTWARE\\Microsoft\\ServerManager\\ServicingStorage\\ServerComponentCache" -Confirm:$False -Recurse -Force
    EOH
    action :run
  end

  ## Override configuration files and SIF modules
  # Fix for http://andrewsutherland.azurewebsites.net/2019/05/01/installing-sitecore-experience-commerce-9-1-with-default-storefront-tenant-and-site/
  remote_directory install['root'] do
    source "sif/#{sitecore['version']}"
    action :create
  end

  # Open required ports
  powershell_script 'Enable ports for Commerce' do
    code <<-EOH
      netsh advfirewall firewall add rule name="SC Commerce Biz" dir=in localport=#{commerce['port_biz']} protocol=TCP action=allow
      netsh advfirewall firewall add rule name="SC Commerce Ops" dir=in localport=#{commerce['port_ops']} protocol=TCP action=allow
    EOH
    action :run
  end
end

action :install do
  install = new_resource.options['install']
  sql = new_resource.options['sql']
  solr = new_resource.options['solr']
  sitecore = new_resource.options['sitecore']
  commerce = new_resource.options['commerce']
  install_storefront = new_resource.install_storefront

  ## Generate installation script from template
  script_file_path = "#{install['commerce_sif_content_path']}/install.ps1"
  template script_file_path do
    source "install.#{sitecore['version']}.ps1.erb"
    variables(
      'install' => install,
      'sql' => sql,
      'solr' => solr,
      'sitecore' => sitecore,
      'commerce' => commerce,
      'install_storefront' => install_storefront)
  end

  ## Run installation script
  scp_windows_powershell_script_elevated 'Install Sitecore Commerce' do
    code script_file_path
    cwd install['commerce_sif_content_path']
    action :run
    timeout 7200 # 2h
  end
end

action :fix_storefront do
  sitecore = new_resource.options['sitecore']
  commerce = new_resource.options['commerce']

  ## Set Storefront hostname
  scp_sitecore_common_spe_remote 'Set Storefront host name' do
    site_url sitecore['site_url']
    code <<-EOH
      $hostName = "#{commerce['storefront_hostname']}"
      Write-Output "Setting Storefront Host Name to $hostName"
      $itemPath = "master:/content/Sitecore/Storefront/Settings/Site Grouping/Storefront"
      Set-ItemProperty -Path $itemPath -Name "HostName" -Value $hostName
      Publish-Item -Path $itemPath -RepublishAll
      Write-Output "Storefront Host Name set to $hostName";
    EOH
  end
end
