version_script_code = '$PSVersionTable.PSVersion'
version_script_result = '5'

describe powershell(version_script_code) do
  its('stdout') { should include version_script_result }
end
