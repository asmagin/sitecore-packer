property :package_full_path, String
property :package_url, String
property :security_protocol, String, default: 'Tls12'

default_action :install

action :install do
  psmodules_path = 'C:/Program Files/WindowsPowerShell/Modules'

  # Download module
  powershell_script "Download PS module from #{new_resource.package_url}" do
    code <<-EOH

      $ProgressPreference='SilentlyContinue';

      $package_url = "#{new_resource.package_url}"
      $package_full_path = "#{new_resource.package_full_path}"

      if(-not(Test-Path $package_full_path)) {
        if($package_url.StartsWith("https")) {
          [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::#{new_resource.security_protocol}
        }
        Invoke-WebRequest -Uri $package_url -OutFile $package_full_path -UseBasicParsing
      }

    EOH
    timeout 600
    action :run
  end

  # Exctract module
  powershell_script "Unpack module to #{psmodules_path}" do
    code <<-EOH

      & 7z x "#{new_resource.package_full_path}" -o"#{psmodules_path}" -aoa

    EOH
    action :run
  end
end
