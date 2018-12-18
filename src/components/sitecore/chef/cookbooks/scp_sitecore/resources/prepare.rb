property :options, Hash, required: true

action :enable_contained_db_auth do
  # Enabled contained database authentication
  script_file_name = 'enable-containers.sql'
  script_file_path = "c:/tmp/#{script_file_name}"
  cookbook_file script_file_path do
    source script_file_name
    cookbook 'scp_sitecore'
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
    cookbook 'scp_sitecore'
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
      :password => new_resource.options['sql']['sa_password']
    )
  end

  powershell_script 'Enabled SA login' do
    code "Invoke-Sqlcmd -InputFile '#{script_file_path}' -ServerInstance 'localhost'"
    action :run
  end
end

action :install_and_update_sif do
  # Install & update SIF
  powershell_script 'Install & update SIF' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';
      Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2 -InstallationPolicy Trusted;
      Install-Module SitecoreInstallFramework -RequiredVersion 1.2.1 -Repository SitecoreGallery;
      Update-Module SitecoreInstallFramework -RequiredVersion 1.2.1;
    EOH
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