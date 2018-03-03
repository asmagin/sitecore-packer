default['gusztavvargadr_sitecore']['prepare'] = {
  'sql' => {
    'sa_password' => 'Vagrant42',
  },
  'chocolatey_packages' => {
    'webpi' => {
      'elevated' => true,
    },
    'nodejs.install' => {
      'version' => '8.9.4',
      'elevated' => true,
    },
  },
  'webpi_packages' => {
    'WDeploy36' => {
      'accept_eula' => true,
      'elevated' => true,
    },
    'UrlRewrite2' => {
      'accept_eula' => true,
      'elevated' => true,
    },
    'DACFX' => {
      'accept_eula' => true,
      'elevated' => true,
    },
    'SQLDOM' => {
      'accept_eula' => true,
      'elevated' => true,
    },
  },
}