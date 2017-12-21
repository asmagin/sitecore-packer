default['gusztavvargadr_consul']['server'] = {
  'version' => '0.9.3',
  'config' => {
    'options' => {
      'ui' => true,
      'node_name' => '',
      'retry_join' => [],
      'encrypt' => '',
      'acl_datacenter' => 'dc1',
      'acl_agent_token' => '',
      'server' => true,
      'bootstrap_expect' => 1,
      'acl_default_policy' => 'deny',
      'acl_master_token' => '',
    },
  },
  'client_addr' => '0.0.0.0',
}
