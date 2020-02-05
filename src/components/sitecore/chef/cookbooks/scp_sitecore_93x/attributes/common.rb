default['scp_sitecore_93x']['common'] = {
  'sitecore' => {
    'cert_path' => 'c:/certificates',
    'password' => 'vagrant',
    'prefix' => 'sc9',
    'root' => 'c:/tmp/sitecore',
    'site_path' => 'c:/inetpub/wwwroot/sc9.local',
    'xconnect_path' => 'c:/inetpub/wwwroot/sc9.xconnect',
    'identityserver_path' => 'c:/inetpub/wwwroot/sc9.identityserver',
    'solr_root' => 'C:/tools/solr-8.1.1',
    'solr_service' => 'SOLR',
    'solr_url' => 'https://localhost:8983/solr',
    'sql_admin_user' => 'sa',
    'sql_admin_password' => 'Vagrant42',
    'sql_collectionuser_password' => 'Test12345',
    'sql_server' => 'localhost',
  },
  'sql' => {
    'sa_password' => 'Vagrant42',
  },
}
