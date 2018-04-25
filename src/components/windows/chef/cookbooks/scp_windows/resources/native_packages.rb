property :native_packages_options, Hash, required: true

default_action :install

action :install do
  native_packages_options.each do |native_package_name, native_package_options|
    scp_windows_native_package native_package_name do
      native_package_options native_package_options ? native_package_options : {}
      action :install
    end
  end
end
