default['scp_sitecore_90x']['prepare'] = {
  'sql' => {
    'sa_password' => 'Vagrant42',
  },
  'chocolatey_packages' => {
    'webpi' => {
      'elevated' => true,
    },
    'nodejs-lts' => {
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
