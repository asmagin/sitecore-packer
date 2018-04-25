executable_path = 'C:/Program Files/dotnet/dotnet.exe'

describe file(executable_path) do
  it { should exist }
end
