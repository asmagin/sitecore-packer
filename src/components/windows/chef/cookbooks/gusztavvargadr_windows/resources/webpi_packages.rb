property :packages_options, Hash, required: true

default_action :install

action :install do
  packages_options.each do |package_name, package_options|
    gusztavvargadr_windows_webpi_package package_name do
      package_options package_options ? package_options : {}
      action :install
    end
  end
end
