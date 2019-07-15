property :site_url, String, required: true, default: 'http://sc9.local'

default_action :rebuild_link_db

action :rebuild_link_db do
  scp_windows_powershell_script_elevated 'Rebuild link DBs' do
    code <<-EOH
        Import-Module -Name SPE
        $session = New-ScriptSession -Username admin -Password b -ConnectionUri "#{new_resource.site_url}" -Timeout 300000
        $jobId = Invoke-RemoteScript -Session $session -AsJob -ScriptBlock {
          Write-Output "Rebuilding link DBs..."
            "core", "master" | Get-Database | 
              ForEach-Object { 
                  [Sitecore.Globals]::LinkDatabase.Rebuild($_)
              }
        }
        Wait-RemoteScriptSession -Session $session -Id $jobId -Delay 5
        Stop-ScriptSession -Session $session
      EOH
    action :run
  end
end
