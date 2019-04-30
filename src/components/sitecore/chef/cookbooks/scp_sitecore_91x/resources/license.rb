property :options, Hash, required: true

action :cleanup_licenses do
  sitecore = new_resource.options['sitecore']
  prefix = sitecore['prefix']

  batch 'cleanup_licenses' do
    code <<-EOH

      del /f C:\\inetpub\\wwwroot\\#{prefix}.local\\App_Data\\license.xml
      del /f C:\\inetpub\\wwwroot\\#{prefix}.xconnect\\App_Data\\license.xml
      del /f C:\\inetpub\\wwwroot\\#{prefix}.xconnect\\App_Data\\jobs\\continuous\\AutomationEngine\\App_Data\\license.xml
      del /f C:\\inetpub\\wwwroot\\#{prefix}.xconnect\\App_Data\\jobs\\continuous\\IndexWorker\\App_Data\\license.xml
      del /f C:\\inetpub\\wwwroot\\#{prefix}.identityserver\\sitecoreruntime\\license.xml

      EOH
  end
end

action :create_license_symlinks do
  sitecore = new_resource.options['sitecore']
  prefix = sitecore['prefix']

  batch 'create_license_symlinks' do
    code <<-EOH

      mklink C:\\inetpub\\wwwroot\\#{prefix}.local\\App_Data\\license.xml C:\\vagrant\\license.xml
      mklink C:\\inetpub\\wwwroot\\#{prefix}.xconnect\\App_Data\\license.xml C:\\vagrant\\license.xml
      mklink C:\\inetpub\\wwwroot\\#{prefix}.xconnect\\App_Data\\jobs\\continuous\\AutomationEngine\\App_Data\\license.xml C:\\vagrant\\license.xml
      mklink C:\\inetpub\\wwwroot\\#{prefix}.xconnect\\App_Data\\jobs\\continuous\\IndexWorker\\App_Data\\license.xml C:\\vagrant\\license.xml
      mklink C:\\inetpub\\wwwroot\\#{prefix}.identityserver\\sitecoreruntime\\license.xml C:\\vagrant\\license.xml

      EOH
  end
end
