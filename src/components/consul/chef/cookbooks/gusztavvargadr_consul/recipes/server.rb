node.override['consul'] = node['gusztavvargadr_consul']['server']

include_recipe 'consul::default'
