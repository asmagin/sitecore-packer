scp_develop_debugger '' do
  options node['scp_develop']['debugger']
  action :install
end
