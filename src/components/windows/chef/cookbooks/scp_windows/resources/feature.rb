property :feature_name, String, name_property: true
property :feature_options, Hash, required: true

default_action :install

action :install do
  scp_windows_powershell_script_elevated "Install Feature '#{feature_name}'" do
    code <<-EOH
      Get-WindowsOptionalFeature -Online | Where { $_.FeatureName -match "#{feature_name}" } | Where { $_.State -ne "Enabled" } | ForEach { Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All -NoRestart }
    EOH
    action :run
  end
end
