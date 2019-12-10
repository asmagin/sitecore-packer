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
  scp_packer_cookbook 'solr750'
  scp_packer_cookbook 'solr811'

  # Sitecore 9.0
  scp_packer_cookbook 'sc900'
  scp_packer_cookbook 'sc901'
  scp_packer_cookbook 'sc902'

  # Sitecore 9.0 SXA JSS
  scp_packer_cookbook 'sc902_jss1100'
  scp_packer_cookbook 'sc902_sxa171_jss1100'
  scp_packer_cookbook 'sc902_sxa180'
  scp_packer_cookbook 'sc902_sxa180_jss1100'

  # Sitecore 9.1
  scp_packer_cookbook 'sc910'
  scp_packer_cookbook 'sc911'

  # Sitecore 9.1 SXA JSS
  scp_packer_cookbook 'sc910_sxa180'
  scp_packer_cookbook 'sc910_jss1100'
  scp_packer_cookbook 'sc910_sxa180_jss1100'
  scp_packer_cookbook 'sc911_sxa181'
  scp_packer_cookbook 'sc911_jss1101'
  scp_packer_cookbook 'sc911_jss1110'
  scp_packer_cookbook 'sc911_sxa181_jss1101'
  scp_packer_cookbook 'sc911_sxa181_jss1110'

  # Sitecore 9.2
  scp_packer_cookbook 'sc920'

  # Sitecore 9.2 SXA JSS
  scp_packer_cookbook 'sc920_sxa190'
  scp_packer_cookbook 'sc920_jss1200'
  scp_packer_cookbook 'sc920_sxa190_jss1200'

  # Sitecore Commerce 9.0
  scp_packer_cookbook 'xc901'
  scp_packer_cookbook 'xc902'
  scp_packer_cookbook 'xc903'
  scp_packer_cookbook 'xc903_sxa180_storefront'

  # Sitecore Commerce 9.1
  scp_packer_cookbook 'xc910'
  scp_packer_cookbook 'xc910_sxa181_storefront'

  scp_cookbook 'components', 'windows'
  scp_cookbook 'components', 'virtualbox'
  scp_cookbook 'components', 'iis'
  scp_cookbook 'components', 'sql'

  scp_cookbook 'components', 'solr'
  scp_cookbook 'components', 'sitecore', 'common'
  scp_cookbook 'components', 'sitecore', '90x'
  scp_cookbook 'components', 'sitecore', '91x'
  scp_cookbook 'components', 'sitecore', '92x'
  scp_cookbook 'components', 'sitecore', 'modules'
  scp_cookbook 'components', 'commerce'
  #scp_cookbook 'components', 'commerce', 'common'
  scp_cookbook 'components', 'commerce', '90x'
  scp_cookbook 'components', 'commerce', '91x'
  scp_cookbook 'components', 'develop'
end

def scp_packer_cookbook(type, name = '')
  name = type if name.empty?
  cookbook "scp_packer_#{name}", path: "#{File.dirname(__FILE__)}/src/containers/#{type}/chef/cookbooks/scp_packer_#{name}"
end
