version_script_code = 'NuGet'
version_script_result = 'NuGet Version:'

describe powershell(version_script_code) do
  its('stdout') { should include version_script_result }
end
