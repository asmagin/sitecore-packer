property :site_url, String, required: true, default: 'http://sc9.local'

default_action :warmup

action :warmup do
  scp_windows_powershell_script_elevated 'Warmup Sitecore' do
    code <<-EOH
        Write-Output "Warming up #{new_resource.site_url}..."
        Invoke-WebRequest "#{new_resource.site_url}" -UseBasicParsing
      EOH
    action :run
  end
end
