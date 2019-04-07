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

  # MSSQL
  scp_packer_cookbook 'sql16d'

  # SOLR
  scp_packer_cookbook 'solr662'
  scp_packer_cookbook 'solr721'

  # Sitecore 9.0
  scp_packer_cookbook 'sc900'
  scp_packer_cookbook 'sc901'
  scp_packer_cookbook 'sc902'

  # Sitecore 9.0 SXA JSS
  scp_packer_cookbook 'sc902_sxa171_jss1100'
  scp_packer_cookbook 'sc902_sxa180_jss1100'

  # Sitecore 9.1
  scp_packer_cookbook 'sc910'

  # Sitecore 9.1 SXA JSS
  scp_packer_cookbook 'sc910_sxa180'
  scp_packer_cookbook 'sc910_jss1100'
  scp_packer_cookbook 'sc910_sxa180_jss1100'

  # Sitecore Commerce 9.0
  scp_packer_cookbook 'xc901'
  scp_packer_cookbook 'xc902'

  scp_cookbook 'components', 'windows'
  scp_cookbook 'components', 'virtualbox'
  scp_cookbook 'components', 'iis'
  scp_cookbook 'components', 'sql'

  scp_cookbook 'components', 'solr'
  scp_cookbook 'components', 'sitecore', '90x'
  scp_cookbook 'components', 'sitecore', '91x'
  scp_cookbook 'components', 'sitecore_modules'
  scp_cookbook 'components', 'commerce'
  scp_cookbook 'components', 'develop'
end

def scp_packer_cookbook(type, name = '')
  name = type if name.empty?
  cookbook "scp_packer_#{name}", path: "#{File.dirname(__FILE__)}/src/containers/#{type}/chef/cookbooks/scp_packer_#{name}"
end
