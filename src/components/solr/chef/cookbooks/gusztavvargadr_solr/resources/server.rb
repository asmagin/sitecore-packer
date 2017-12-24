property :server_options, Hash, required: true

default_action :install

action :prepare do
  java_home = new_resource.server_options['java_path']
  java_path = "#{java_home}/bin"

  env 'JAVA_HOME' do
    value java_home
    action :create
  end

  windows_path '' do
    path java_path
    action :add
  end
end

action :install do
  # install SOLR prerequisites
  gusztavvargadr_windows_chocolatey_packages '' do
    chocolatey_packages_options server_options['chocolatey_packages_options']
  end

  # install solr service
  gusztavvargadr_solr_nssms '' do
    services_options server_options['services_options']
  end

  # setup HTTPS for SOLR
  directory_path = "#{Chef::Config[:file_cache_path]}/gusztavvargadr_solr/server"

  directory directory_path do
    recursive true
    action :create
  end

  script_file_name = 'solr-ssl.ps1'
  script_file_path = "#{directory_path}/#{script_file_name}"
  cookbook_file script_file_path do
    source script_file_name
    cookbook 'gusztavvargadr_solr'
    action :create
  end

  # Generate SSL cert
  powershell_script "Generate SSL cert" do
    code "& '#{script_file_path}' -KeystoreFile '#{server_options['solr_path']}/server/etc/solr-ssl.keystore.jks' -Clobber"
    action :run
  end

  # Enable HTTPS for SOLR
  cookbook_file "#{server_options['solr_path']}/bin/solr.in.cmd" do
    source 'solr.in.cmd'
    cookbook 'gusztavvargadr_solr'
    action :create
  end
end
