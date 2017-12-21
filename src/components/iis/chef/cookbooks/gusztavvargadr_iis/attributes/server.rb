default['gusztavvargadr_iis']['server'] = {
  'features' => {
    'IIS' => {},
  },
  'native_packages' => {
    '.NET Core 1.1.4 Windows Server Hosting' => {
      'source' => 'https://download.microsoft.com/download/6/F/B/6FB4F9D2-699B-4A40-A674-B7FF41E0E4D2/DotNetCore.1.0.7_1.1.4-WindowsHosting.exe',
      'install' => [
        '/install',
        '/quiet',
        '/norestart',
      ],
    },
    '.NET Core 2.0.0 Windows Server Hosting' => {
      'source' => 'https://download.microsoft.com/download/B/1/D/B1D7D5BF-3920-47AA-94BD-7A6E48822F18/DotNetCore.2.0.0-WindowsHosting.exe',
      'install' => [
        '/install',
        '/quiet',
        '/norestart',
      ],
    },
  },
}
