property :chocolatey_package_name, String, name_property: true
property :chocolatey_package_options, Hash, required: true

default_action :install

action :install do
  chocolatey_package_list = powershell_out("choco list --local-only --exact #{chocolatey_package_name}").stdout
  return if chocolatey_package_list.downcase.include?(chocolatey_package_name.downcase)

  chocolatey_package_version = chocolatey_package_options['version']
  chocolatey_package_install = chocolatey_package_options['install'].nil? ? {} : chocolatey_package_options['install']
  chocolatey_package_elevated = chocolatey_package_options['elevated']

  chocolatey_package_script_name = "Install Chocolatey package '#{chocolatey_package_name}'"
  chocolatey_package_script_code = "choco install #{chocolatey_package_name} --confirm"
  chocolatey_package_script_code = "#{chocolatey_package_script_code} --version #{chocolatey_package_version}" unless chocolatey_package_version.to_s.empty?
  chocolatey_package_install.each do |chocolatey_package_install_name, chocolatey_package_install_value|
    chocolatey_package_script_code = "#{chocolatey_package_script_code} --#{chocolatey_package_install_name}"
    chocolatey_package_script_code = "#{chocolatey_package_script_code} #{chocolatey_package_install_value}" unless chocolatey_package_install_value.to_s.empty?
  end

  if chocolatey_package_elevated
    scp_windows_powershell_script_elevated chocolatey_package_script_name do
      code chocolatey_package_script_code
      action :run
    end
  else
    powershell_script chocolatey_package_script_name do
      code chocolatey_package_script_code
      action :run
    end
  end
end
