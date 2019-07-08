property :package_url, String, required: true
property :package_path, String, required: true
property :user, String, required: true
property :password, String, required: true

default_action :download_sitecore_package

action :download_sitecore_package do
  powershell_script "Download Sitecore Package: #{new_resource.package_path}" do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';
      if(-not(Test-Path "#{new_resource.package_path}")) {
        $loginRequest = Invoke-RestMethod `
          -Uri "https://dev.sitecore.net/api/authorization" `
          -Method Post `
          -ContentType "application/json" `
          -Body "{username: '#{new_resource.user}', password: '#{new_resource.password}'}" `
          -SessionVariable session `
          -UseBasicParsing;

        Invoke-WebRequest `
          -Uri "#{new_resource.package_url}" `
          -WebSession $session `
          -OutFile "#{new_resource.package_path}" `
          -UseBasicParsing;
      }
    EOH
    action :run
  end
end
