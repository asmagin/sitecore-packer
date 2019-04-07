action :copy_license do
  directory 'C:/vagrant' do
    recursive true
    action :create
  end

  cookbook_file 'C:/vagrant/license.xml' do
    source 'license.xml'
    cookbook 'scp_sitecore_modules'
    sensitive true
    action :create
  end
end

action :remove_license do
  batch 'remove license' do
    code <<-EOH

      rd C:\\vagrant /s /q

      EOH
  end
end
