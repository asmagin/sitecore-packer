default['gusztavvargadr_consul']['client'] = {
  'version' => '0.9.3',
  'config' => {
    'options' => {
      'ui' => true,
      'node_name' => '',
      'retry_join' => [],
      'encrypt' => '',
      'acl_datacenter' => 'dc1',
      'acl_agent_token' => '',
      'acl_token' => '',
    },
  },
  'client_addr' => '127.0.0.1',
}
