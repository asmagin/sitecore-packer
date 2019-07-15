property :site_url, String, required: true, default: 'http://sc9.local'

default_action :solr_reindex

action :solr_reindex do
  scp_windows_powershell_script_elevated 'Reindex SOLR' do
    code <<-EOH
        Import-Module -Name SPE
        $session = New-ScriptSession -Username admin -Password b -ConnectionUri "#{new_resource.site_url}" -Timeout 300000
        $jobId = Invoke-RemoteScript -Session $session -AsJob -ScriptBlock {
            Write-Output "Start reindexing SOLR cores..."
            (Get-SearchIndex).ForEach({
                Write-Output "Core: $($_.Core)"
                Write-Output " - Rebuilding index...";
                $_.Rebuild();
                Write-Output "";
            });
            Write-Output "Stop reindexing SOLR cores..."
        }
        Wait-RemoteScriptSession -Session $session -Id $jobId -Delay 5
        Stop-ScriptSession -Session $session
      EOH
    action :run
  end
end
