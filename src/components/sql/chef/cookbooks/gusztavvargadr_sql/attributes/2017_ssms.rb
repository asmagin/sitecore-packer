default['gusztavvargadr_sql']['2017_ssms'] = {
  'native_packages' => {
    'SSMS 17.3' => {
      'source' => 'https://download.microsoft.com/download/3/C/7/3C77BAD3-4E0F-4C6B-84DD-42796815AFF6/SSMS-Setup-ENU.exe',
      'install' => [
        '/install',
        '/quiet',
        '/norestart',
      ],
      'executable' => 'C:/Program Files (x86)/Microsoft SQL Server/140/Tools/Binn/ManagementStudio/Ssms.exe',
      'elevated' => true,
    },
  },
}
