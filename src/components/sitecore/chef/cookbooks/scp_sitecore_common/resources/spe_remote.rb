property :site_url, String, required: true
property :code, String, required: true

default_action :spe_remote

action :spe_remote do
  scp_windows_powershell_script_elevated 'Set Storefront host name' do
    code <<-EOH
      Import-Module -Name SPE
      $session = New-ScriptSession -Username admin -Password b -ConnectionUri "#{new_resource.site_url}"
      $jobId = Invoke-RemoteScript -Session $session -AsJob -ScriptBlock {
        #{new_resource.code}
      }
      Wait-RemoteScriptSession -Session $session -Id $jobId -Delay 5
      Stop-ScriptSession -Session $session
    EOH
    action :run
  end
end
