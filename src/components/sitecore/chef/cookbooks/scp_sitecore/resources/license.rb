action :copy_license do
  directory 'C:/vagrant' do
    recursive true
    action :create
  end

  cookbook_file 'C:/vagrant/license.xml' do
    source 'license.xml'
    cookbook 'scp_sitecore'
    action :create
  end
end

action :remove_license do
  batch 'remove license' do
    code <<-EOH

      rd C:\\vagrant /s /q

      EOH
  end
end

action :cleanup_licenses do
  batch 'cleanup_licenses' do
    code <<-EOH

      del /f C:\\inetpub\\wwwroot\\sc9.local\\App_Data\\license.xml
      del /f C:\\inetpub\\wwwroot\\sc9.xconnect\\App_Data\\license.xml
      del /f C:\\inetpub\\wwwroot\\sc9.xconnect\\App_Data\\jobs\\continuous\\AutomationEngine\\App_Data\\license.xml
      del /f C:\\inetpub\\wwwroot\\sc9.xconnect\\App_Data\\jobs\\continuous\\IndexWorker\\App_Data\\license.xml

      EOH
  end
end

action :create_license_symlinks do
  batch 'create_license_symlinks' do
    code <<-EOH

      mklink C:\\inetpub\\wwwroot\\sc9.local\\App_Data\\license.xml C:\\vagrant\\license.xml
      mklink C:\\inetpub\\wwwroot\\sc9.xconnect\\App_Data\\license.xml C:\\vagrant\\license.xml
      mklink C:\\inetpub\\wwwroot\\sc9.xconnect\\App_Data\\jobs\\continuous\\AutomationEngine\\App_Data\\license.xml C:\\vagrant\\license.xml
      mklink C:\\inetpub\\wwwroot\\sc9.xconnect\\App_Data\\jobs\\continuous\\IndexWorker\\App_Data\\license.xml C:\\vagrant\\license.xml

      EOH
  end
end
