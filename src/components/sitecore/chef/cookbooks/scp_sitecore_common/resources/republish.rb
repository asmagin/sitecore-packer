property :site_url, String, required: true, default: 'http://sc9.local'

default_action :republish

action :republish do
  scp_windows_powershell_script_elevated 'Republish whole Sitecore tree' do
    code <<-EOH
        Import-Module -Name SPE
        Write-Output "Start republishing..."
        $session = New-ScriptSession -Username admin -Password b -ConnectionUri "#{new_resource.site_url}" -Timeout 300000
        $jobId = Invoke-RemoteScript -Session $session -AsJob -ScriptBlock {
          Publish-Item -Path "master:\\sitecore" -Recurse -PublishMode Full -RepublishAll
        }
        Wait-RemoteScriptSession -Session $session -Id $jobId -Delay 5
        Stop-ScriptSession -Session $session
      EOH
    action :run
  end
end
