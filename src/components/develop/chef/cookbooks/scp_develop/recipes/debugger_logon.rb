scp_develop_debugger '' do
  options node['scp_develop']['debugger']
  action :install
end

scp_develop_debugger '' do
  options node['scp_develop']['debugger']
  action :configure_firewall
end

scp_develop_debugger '' do
  options node['scp_develop']['debugger']
  action :configure_msvsmon_logon_startup
end
