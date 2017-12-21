node.override['consul'] = node['gusztavvargadr_consul']['client']

include_recipe 'consul::default'
