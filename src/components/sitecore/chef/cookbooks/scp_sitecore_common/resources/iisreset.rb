default_action :iisreset

action :iisreset do
  scp_windows_powershell_script_elevated 'Restart IIS' do
    code <<-EOH
      Write-Output "Stopping IIS..."
      iisreset -stop
      iisreset -stop

      Write-Output "Wait 10 seconds to give thing time to settle..."
      Start-Sleep -Second 10

      Write-Output "Starting IIS..."
      iisreset -start
      iisreset -start

    EOH
    action :run
  end
end
