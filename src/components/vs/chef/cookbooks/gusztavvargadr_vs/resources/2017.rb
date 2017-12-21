property :edition, String, name_property: true

action :install do
  gusztavvargadr_windows_native_packages '' do
    native_packages_options node['gusztavvargadr_vs']["2017_#{edition}"]['native_packages']
  end
end
