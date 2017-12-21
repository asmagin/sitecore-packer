version_script_code = 'git'
version_script_result = 'usage: git'

describe powershell(version_script_code) do
  its('stdout') { should include version_script_result }
end
