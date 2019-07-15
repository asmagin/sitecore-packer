property :options, Hash, required: true
property :secrets, Hash, required: true

default_action :install

# Install Azure Toolkit
action :install do
  config = new_resource.options['config']

  user = new_resource.secrets['user']
  password = new_resource.secrets['password']

  # Ensure directory exists
  scripts_directory_path = config['root'].to_s
  directory scripts_directory_path do
    recursive true
    action :create
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

  # Extract archive
  azure_toolkit_path = "#{config['tools_path']}/#{config['package_original_name']}"
  powershell_script 'Unpack Azure Toolkit' do
    code <<-EOH
      & 7z x "#{config['package_full_path']}" -o"#{azure_toolkit_path}" -aoa
    EOH
    action :run
  end

  # Generate install template
  sitecore_version_script = <<-EOH
    [xml]$XmlDocument = Get-Content -Path "#{config['site_path']}/sitecore/shell/sitecore.version.xml";
    $version = $XmlDocument.information.version;
    $host.UI.Write("$($version.major).$($version.minor).$($version.build)");
  EOH
  sitecore_version = powershell_out(sitecore_version_script).stdout

  config_for_script_template = config
  cloud_bootload_package_path = "#{azure_toolkit_path}/resources/#{sitecore_version}/Addons/Sitecore.Cloud.Integration.Bootload.wdp.zip"
  config_for_script_template['package_full_path'] = cloud_bootload_package_path.to_s

  script_file_name = "install_#{config['module']}.ps1"
  script_file_path = "#{config['root']}/#{script_file_name}"
  template script_file_path do
    source 'install_module.ps1.erb'
    variables('config' => config_for_script_template)
  end

  # Install module
  powershell_script "Install #{config['package_original_name']}" do
    code script_file_path
    cwd config['root']
    timeout 600
    action :run
  end

  # Copy cloud bootload vagrant configuration
  remote_directory config['site_path'] do
    source 'azuretoolkit'
    action :create
  end
end
