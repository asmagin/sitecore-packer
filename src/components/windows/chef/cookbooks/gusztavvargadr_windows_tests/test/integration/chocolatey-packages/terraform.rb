version_script_code = 'terraform version'
version_script_result = 'Terraform v0.8.8'

describe powershell(version_script_code) do
  its('stdout') { should include version_script_result }
end
