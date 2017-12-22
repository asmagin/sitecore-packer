default['gusztavvargadr_solr']['server'] = {
  'java_path' => 'C:/Program Files/Java/jre1.8.0_151',
  'solr_path' => 'C:/tools/solr-6.6.2',
  'chocolatey_packages_options' => {
    'jre8' => {
      'version' => '8.0.151',
      'elevated' => true,
    },
    'solr' => {
      'version' => '6.6.2',
      'elevated' => true,
    },
    'nssm' => {
      'elevated' => true,
    },
  },
  'services_options' => {
    'SOLR' => {
      'program' => 'C:/tools/solr-6.6.2/bin/solr.cmd',
      'args' => 'start -f -p 8983',
      'parameters' => {
        'DisplayName' => 'Solr 6.6.2',
        'Description' => 'Solr 6.6.2 on port 8983',
        'Start' => 'SERVICE_AUTO_START',
      }
    },
  },
}
