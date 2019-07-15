property :path, String, required: true
property :xpath, String, required: true
property :value, String, required: true
property :namespace, String, default: ''

default_action :set_xml_attribute

action :set_xml_attribute do
  powershell_script '' do
    code <<-EOH
      $ProgressPreference='SilentlyContinue';

      $xml = [xml](Get-Content '#{new_resource.path}')
      $node = $xml | Select-Xml '#{new_resource.xpath}' -Namespace @{ ns='#{new_resource.namespace}' }
      $node.Node.'#text' = '#{new_resource.value}'
      $xml.Save('#{new_resource.path}')

    EOH
    action :run
  end
end
