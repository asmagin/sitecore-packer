property :source, String, required: true
property :destination, String, required: true

default_action :unzip

action :unzip do
  powershell_script "Extract #{new_resource.source} to #{new_resource.destination}" do
    code <<-EOH
      & 7z x "#{new_resource.source}" -o"#{new_resource.destination}" -aoa
    EOH
    action :run
  end
end
