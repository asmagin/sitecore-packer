property :license_cookbook, String, required: true, default: 'scp_sitecore_common'
property :license_filename, String, required: true, default: 'license.xml'
property :license_dir_path, String, required: true, default: 'C:\\vagrant'

action :copy_license do
  directory new_resource.license_dir_path do
    recursive true
    action :create
  end

  cookbook_file "#{new_resource.license_dir_path}\\#{new_resource.license_filename}" do
    source new_resource.license_filename
    cookbook new_resource.license_cookbook
    sensitive true
    action :create
  end
end

action :remove_license do
  batch 'Remove license' do
    code <<-EOH
      rd #{new_resource.license_dir_path} /s /q
      EOH
  end
end
