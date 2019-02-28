default['scp_solr']['solr721'] = {
  'java_path' => 'C:/Program Files/Java/jre1.8.0_151',
  'solr_path' => 'C:/tools/solr-7.2.1',
  'chocolatey_packages_options' => {
    'jre8' => {
      'version' => '8.0.151',
      'elevated' => true,
    },
    'solr' => {
      'version' => '7.2.1',
      'elevated' => true,
    },
    'nssm' => {
      'elevated' => true,
    },
  },
  'services_options' => {
    'SOLR' => {
      'program' => 'C:/tools/solr-7.2.1/bin/solr.cmd',
      'args' => 'start -f -p 8983',
      'parameters' => {
        'DisplayName' => 'Solr 7.2.1',
        'Description' => 'Solr 7.2.1 on port 8983',
        'Start' => 'SERVICE_AUTO_START',
      },
    },
  },
}
