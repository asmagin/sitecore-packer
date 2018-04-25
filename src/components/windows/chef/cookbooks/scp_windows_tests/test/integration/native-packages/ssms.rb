executable_path = 'C:/Program Files (x86)/Microsoft SQL Server/130/Tools/Binn/ManagementStudio/Ssms.exe'

describe file(executable_path) do
  it { should exist }
end
