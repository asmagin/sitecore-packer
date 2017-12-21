property :chocolatey_packages_options, Hash, required: true

default_action :install

action :install do
  chocolatey_packages_options.each do |chocolatey_package_name, chocolatey_package_options|
    gusztavvargadr_windows_chocolatey_package chocolatey_package_name do
      chocolatey_package_options chocolatey_package_options ? chocolatey_package_options : {}
      action :install
    end
  end
end
