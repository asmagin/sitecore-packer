default['gusztavvargadr_sitecore']['prepare'] = {
  'chocolatey_packages' => {
    'webpi' => {
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