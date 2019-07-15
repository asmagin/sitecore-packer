default_action :install

action :install do
  packages = {
    'nodejs-lts' => {
      'elevated' => true,
    },
  }
  scp_windows_chocolatey_packages 'NodeJS LTS' do
    chocolatey_packages_options packages
  end
end
