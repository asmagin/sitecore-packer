gusztavvargadr_virtualbox_guest_additions '' do
  guest_additions_options node['gusztavvargadr_virtualbox']['guest_additions']
  action :install
end
