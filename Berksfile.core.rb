directory = File.dirname(__FILE__)
require "#{directory}/src/components/core/chef/Berksfile.core"

def scp_packer_sources
  scp_sources

  scp_packer_cookbook 'w'
  scp_packer_cookbook 'w', 'virtualbox_iso'
  scp_packer_cookbook 'w', 'virtualbox_ovf'
  # scp_packer_cookbook 'w', 'amazon_ebs'

  scp_packer_cookbook 'w16s'
  scp_packer_cookbook 'dotnet'
  scp_packer_cookbook 'iis'

  scp_packer_cookbook 'sql16d'
  scp_packer_cookbook 'solr'

  # Sitecore 9.0
  scp_packer_cookbook 'sc900'
  scp_packer_cookbook 'sc901'
  scp_packer_cookbook 'sc902'

  # SPE SXA JSS
  scp_packer_cookbook 'sc902m'

  # Sitecore Commerce 9.0
  scp_packer_cookbook 'xc901'
  scp_packer_cookbook 'xc902'

  scp_cookbook 'components', 'windows'
  scp_cookbook 'components', 'virtualbox'
  scp_cookbook 'components', 'iis'
  scp_cookbook 'components', 'sql'

  scp_cookbook 'components', 'solr'
  scp_cookbook 'components', 'sitecore'
  scp_cookbook 'components', 'sitecore_modules'
  scp_cookbook 'components', 'commerce'
  scp_cookbook 'components', 'develop'
end

def scp_packer_cookbook(type, name = '')
  name = type if name.empty?
  cookbook "scp_packer_#{name}", path: "#{File.dirname(__FILE__)}/src/containers/#{type}/chef/cookbooks/scp_packer_#{name}"
end
