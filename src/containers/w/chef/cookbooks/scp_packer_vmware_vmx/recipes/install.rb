powershell_script 'Set Env Value to Skip Disk optimization' do
  code <<-EOH
    [System.Environment]::SetEnvironmentVariable("SkipOptimization", "True", [System.EnvironmentVariableTarget]::Machine)
  EOH
  action :run
end