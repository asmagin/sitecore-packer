property :package_url, String, required: true
property :package_path, String, required: true

default_action :download_package

action :download_package do
  powershell_script "Download Package: #{new_resource.package_path}" do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';
      if(-not(Test-Path "#{new_resource.package_path}")) {
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
