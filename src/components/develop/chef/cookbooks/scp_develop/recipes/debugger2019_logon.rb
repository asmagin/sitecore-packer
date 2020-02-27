scp_develop_debugger2019 '' do
  options node['scp_develop']['debugger2019']
  action :install
end

scp_develop_debugger2019 '' do
  options node['scp_develop']['debugger2019']
  action :configure_firewall
end

scp_develop_debugger2019 '' do
  options node['scp_develop']['debugger2019']
  action :configure_msvsmon_logon_startup
end
