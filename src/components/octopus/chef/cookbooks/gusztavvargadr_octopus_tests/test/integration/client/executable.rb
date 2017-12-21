version_script_code = 'octo'
version_script_result = 'Octopus Deploy Command Line Tool, version'

describe powershell(version_script_code) do
  its('stdout') { should include version_script_result }
end
