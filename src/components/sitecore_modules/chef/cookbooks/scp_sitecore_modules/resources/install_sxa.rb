property :options, Hash, required: true
property :secrets, Hash, required: true

default_action :install

# Install Sitecore Experience Accelerator
action :install do
  config = new_resource.options['config']

  # Ensure directory exists
  scripts_directory_path = config['root'].to_s
  directory scripts_directory_path do
    recursive true
    action :create
  end

  # Install Sitecore Experience Accelerator
  scp_sitecore_modules_install_sitecore_module 'Install Sitecore Experience Accelerator' do
    options new_resource.options
    secrets new_resource.secrets
    action :install
  end
end

action :add_sxa_solr_cores do
  config = new_resource.options['config']

  # Add SOLR cores for Sitecore Experience Accelerator
  sxa_master_index = "#{config['prefix']}_sxa_master_index"
  sxa_web_index = "#{config['prefix']}_sxa_web_index"

  solr_idexes_folder = "#{config['solr_root']}/server/solr"
  source = "#{solr_idexes_folder}/sc9_master_index/conf"
  powershell_script 'Create SXA SOLR cores' do
    code <<-EOH

        Copy-Item "#{source}" -Destination "#{solr_idexes_folder}/#{sxa_master_index}/conf" -Recurse -Force
        Copy-Item "#{source}" -Destination "#{solr_idexes_folder}/#{sxa_web_index}/conf" -Recurse -Force

        switch ("#{config['solr_version']}")
        {
            "6.6.2"
            {
              Invoke-ManageSolrCoreTask -Action "Create" -Address "#{config['solr_url']}" -Arguments @{ Name = "#{sxa_master_index}" }
              Invoke-ManageSolrCoreTask -Action "Create" -Address "#{config['solr_url']}" -Arguments @{ Name = "#{sxa_web_index}" }
            }
            # "7.2.1" and higher
            default
            {
              Invoke-ManageSolrCoreTask -Action "Create" -Address "#{config['solr_url']}" -Arguments @{ name = "#{sxa_master_index}" }
              Invoke-ManageSolrCoreTask -Action "Create" -Address "#{config['solr_url']}" -Arguments @{ name = "#{sxa_web_index}" }
            }
        }

      EOH
    action :run
  end

  config_file = "#{config['site_path']}/#{config['foundation_overrides_path']}/Sitecore.XA.Foundation.Search.Solr.config"
  scp_sitecore_modules_set_xml_attribute 'Update Sitecore.XA.Foundation.Search.Solr.config for sitecore_sxa_master_index' do
    path config_file
    xpath '//index[@id="sitecore_sxa_master_index"]/param[@desc="core"]'
    value sxa_master_index
  end
  scp_sitecore_modules_set_xml_attribute 'Update Sitecore.XA.Foundation.Search.Solr.config for sitecore_sxa_web_index' do
    path config_file
    xpath '//index[@id="sitecore_sxa_web_index"]/param[@desc="core"]'
    value sxa_web_index
  end

  scp_windows_powershell_script_elevated 'PopulateSolrManagedSchema and Rebuild indexes' do
    code <<-EOH

        Import-Module -Name SPE
        $session = New-ScriptSession -Username admin -Password b -ConnectionUri "#{config['site_url']}" -Timeout 300000
        $jobId = Invoke-RemoteScript -Session $session -AsJob -ScriptBlock {
            (Get-SearchIndex -Name *sxa*).ForEach({
                Write-Output "Core: $($_.Core)"
                Write-Output " - Populating solr managed schema...";
                $_.PopulateSolrManagedSchema();
                Write-Output " - Rebuilding index...";
                $_.Rebuild();
                Write-Output "";
            });
        }
        Wait-RemoteScriptSession -Session $session -Id $jobId -Delay 5
        Stop-ScriptSession -Session $session

      EOH
    action :run
  end
end
