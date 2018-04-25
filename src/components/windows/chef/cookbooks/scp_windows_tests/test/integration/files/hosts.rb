target_file_path = 'C:/Temp/hosts'

describe file(target_file_path) do
  it { should exist }
end
