property :services_options, Hash, required: true

default_action :install

action :install do
  services_options.each do |service_name, service_options|
    scp_solr_nssm service_name do
      service_options service_options ? service_options : {}
      action :install
    end
  end
end
