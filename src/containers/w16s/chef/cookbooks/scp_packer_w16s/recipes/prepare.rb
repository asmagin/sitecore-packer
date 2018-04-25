include_recipe 'scp_packer_w::prepare'

scp_windows_uac '' do
  action :disable
end

scp_windows_remote_desktop '' do
  action :enable
end

powershell_script 'Disable AppX Update' do
  code 'Schtasks.exe /change /disable /tn "\Microsoft\Windows\AppxDeploymentClient\Pre-staged app cleanup"'
  action :run
end

powershell_script 'Remove AppX Packages' do
  code <<-EOH
    Get-AppxPackage Microsoft.DesktopAppInstaller | Remove-AppxPackage
    Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
    Get-AppxPackage Microsoft.3DBuilder | Remove-AppxPackage
    Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage
  EOH
  action :run
end

scp_windows_defender '' do
  action :disable
end

powershell_script 'Disable Scheduled Defrag' do
  code 'Schtasks.exe /change /disable /tn "\Microsoft\Windows\Defrag\ScheduledDefrag"'
  action :run
end
