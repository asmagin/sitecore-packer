property :options, Hash, required: true
property :secrets, Hash
property :install_storefront, [true, false], default: false

# Prepare for installation
action :prepare do
  secrets = new_resource.secrets
  install = new_resource.options['install']
  sitecore = new_resource.options['sitecore']

  ## Download and extract - Sitecore Commerce 9.1.0
  scp_sitecore_common_download_sitecore_package 'Sitecore Commerce 9.1.0' do
    package_url install['commerce_package_url']
    package_path install['commerce_package_zip_path']
    user secrets['user']
    password secrets['password']
  end
  scp_sitecore_common_unzip 'Sitecore Commerce 9.1.0' do
    source install['commerce_package_zip_path']
    destination install['root']
  end

  ## Download, extract and delete archive - MSBuild.Microsoft.VisualStudio.Web.targets (to c:\tmp)
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

  ## Download - Sitecore Experience Accelerator
  scp_sitecore_common_download_sitecore_package 'Sitecore Experience Accelerator' do
    package_url install['sitecore_sxa_url']
    package_path install['sitecore_sxa_zip_path']
    user secrets['user']
    password secrets['password']
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

  ## Extract - Sitecore.Commerce.Engine
  scp_sitecore_common_unzip 'Sitecore.Commerce.Engine' do
    source install['commerce_engine_zip_path']
    destination install['commerce_engine_content_path']
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

action :postinstall do
  sitecore = new_resource.options['sitecore']
  commerce = new_resource.options['commerce']

  # Open required ports
  powershell_script 'Enable ports for Commerce' do
    code <<-EOH
      netsh advfirewall firewall add rule name="SC Commerce Biz" dir=in localport=#{commerce['port_biz']} protocol=TCP action=allow
      netsh advfirewall firewall add rule name="SC Commerce Ops" dir=in localport=#{commerce['port_ops']} protocol=TCP action=allow
    EOH
    action :run
  end

  # Add CORS entry to identityserver
  powershell_script 'Add CORS entry to identityserver' do
    code <<-EOH
      [Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")

      $fileName = 'c:/inetpub/wwwroot/#{sitecore['identityserver_hostname']}/Config/production/Sitecore.IdentityServer.Host.xml';

      $content = [System.IO.File]::ReadAllText($fileName);
      $doc = [System.Xml.Linq.XDocument]::Parse($content);

      $allowedCorsOriginsElement = $doc.Descendants("AllowedCorsOrigins");
      $allowedCorsOriginsGroup2Element = [System.Xml.Linq.XElement]::new([System.Xml.Linq.XName]"AllowedCorsOriginsGroup2")
      $allowedCorsOriginsGroup2Element.Value = "https://#{commerce['storefront_hostname']}|http://#{commerce['storefront_hostname']}"
      $allowedCorsOriginsElement.Add($allowedCorsOriginsGroup2Element);

      [System.IO.File]::WriteAllText($fileName, $doc.ToString());
    EOH
    action :run
  end

  ## Add http:80 binding for sc9.local back
  scp_windows_powershell_script_elevated 'Add 80 binding back' do
    code <<-EOH
      New-WebBinding -name "#{sitecore['site_hostname']}" -Protocol http -HostHeader "#{sitecore['site_hostname']}" -Port 80
    EOH
    action :run
  end

  ## Fix BizFx link
  scp_sitecore_common_spe_remote 'Fix BizFx link' do
    site_url sitecore['site_url']
    code <<-EOH
      $bizfx_url = "https://bizfx.#{sitecore['site_hostname']}"
      Write-Output "Setting BizFx url to $bizfx_url"
      $itemPath = "core:/client/Applications/Launchpad/PageSettings/Buttons/Commerce/BusinessTools"
      Set-ItemProperty -Path $itemPath -Name "Link" -Value $bizfx_url
      Write-Output "BizFx url set to $bizfx_url";
    EOH
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

  ## Fix Storefront catalog configuration
  scp_sitecore_common_spe_remote '' do
    site_url sitecore['site_url']
    code <<-EOH
      $itemPath = "master:/content/Sitecore/Storefront/Settings/Commerce/Catalog Configuration"
      Set-ItemProperty -Path $itemPath -Name "Catalog" -Value (Get-Item "master:/content/Sitecore/Storefront/Home/Catalogs/Habitat_Master")
      Set-ItemProperty -Path $itemPath -Name "Start Navigation Category" -Value (Get-Item "master:/content/Sitecore/Storefront/Home/Catalogs/Habitat_Master/Habitat_Master-Departments")
      Publish-Item -Path $itemPath -RepublishAll
    EOH
  end

  ## Fix Habitat catalog template overrides
  scp_sitecore_common_spe_remote '' do
    site_url sitecore['site_url']
    code <<-EOH
      $itemPath = "master:/content/Sitecore/Storefront/Home/Catalogs/Habitat_Master"
      Set-ItemProperty -Path $itemPath -Name "CategoryTemplate" -Value (Get-Item "master:/templates/Project/Sitecore/Commerce Category")
      Set-ItemProperty -Path $itemPath -Name "ProductTemplate" -Value (Get-Item "master:/templates/Project/Sitecore/Commerce Product")
      Set-ItemProperty -Path $itemPath -Name "ProductVariantTemplate" -Value (Get-Item "master:/templates/Project/Sitecore/Commerce Product Variant")
      Set-ItemProperty -Path $itemPath -Name "StaticBundleTemplate" -Value (Get-Item "master:/templates/Project/Sitecore/Commerce Bundle")
      Set-ItemProperty -Path $itemPath -Name "DynamicBundleTemplate" -Value (Get-Item "master:/templates/Project/Sitecore/Commerce Bundle")
      Publish-Item -Path $itemPath -RepublishAll
    EOH
  end
end
