include_recipe 'scp_packer_w::patch'

scp_windows_updates 'Install update fixing Oracle encryption error' do
  msu_source 'http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/05/windows10.0-kb4103723-x64_2adf2ea2d09b3052d241c40ba55e89741121e07e.msu'
  action :install
end

scp_windows_powershell_script_elevated 'Set Oracle encryption policy to mitigated' do
  code <<-EOH
    reg add "HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\\CredSSP\\Parameters" /v AllowEncryptionOracle /t REG_DWORD /d 2 /f
  EOH
  action :run
end